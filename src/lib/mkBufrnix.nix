{
  lib,
  pkgs,
  self ? null,
  config ? {},
}:
with lib; let
  # Import our modules
  optionsDef = import ./bufrnix-options.nix {inherit lib;};
  debug = import ./utils/debug.nix {inherit lib;};
  moduleSystem = import ./module-system.nix {inherit lib;};

  # Extract default values from options
  extractDefaults = options:
    if isOption options
    then options.default or null
    else if isAttrs options
    then mapAttrs (_: extractDefaults) options
    else options;

  defaultConfig = extractDefaults optionsDef.options;

  # Add package defaults
  # For protoc-gen-js on macOS, we have build issues
  # Set to null on Darwin to avoid build failures
  jsPackage =
    if pkgs.stdenv.isDarwin
    then null
    else pkgs.protoc-gen-js;

  packageDefaults = {
    languages = {
      go = {
        package = pkgs.protoc-gen-go;
        grpc.package = pkgs.protoc-gen-go-grpc;
        gateway.package = pkgs.grpc-gateway;
        validate.package = pkgs.protoc-gen-validate;
        connect.package = pkgs.protoc-gen-connect-go;
      };
      php = {
        package = pkgs.protobuf;
        twirp.package = pkgs.protoc-gen-twirp_php;
      };
      js = {
        package = jsPackage;
        es.package = pkgs.protoc-gen-es;
        connect.package = pkgs.protoc-gen-connect-es;
        grpcWeb.package = pkgs.grpc-web;
        twirp.package = pkgs.protoc-gen-twirp_js;
      };
      dart = {
        package = pkgs.protoc-gen-dart;
        grpc.package = pkgs.protoc-gen-dart;
      };
      doc = {
        package = pkgs.protoc-gen-doc;
      };
      swift = {
        package = pkgs.protoc-gen-swift;
      };
    };
  };

  # Merge defaults with user config
  cfg = recursiveUpdate (recursiveUpdate defaultConfig packageDefaults) config;

  # Create module system with our configuration
  modSys = moduleSystem.createModuleSystem {
    inherit config pkgs self;
  };

  # Load language modules based on configuration
  languageNames = attrNames cfg.languages;

  # Function to load a language module if enabled
  loadLanguageModule = language:
    if cfg.languages.${language}.enable
    then
      import ../languages/${language}
      {
        inherit pkgs lib;
        config = cfg;
        cfg = cfg.languages.${language};
      }
    else {};

  # Load all enabled language modules
  loadedLanguageModules = map loadLanguageModule languageNames;

  # Extract runtime inputs from language modules
  languageRuntimeInputs = concatMap (module: module.runtimeInputs or []) loadedLanguageModules;

  # Extract protoc plugins from language modules
  languageProtocPlugins = concatMap (module: module.protocPlugins or []) loadedLanguageModules;

  # Extract initialization hooks from language modules
  languageInitHooks = concatMapStrings (module: module.initHooks or "") loadedLanguageModules;

  # Extract code generation hooks from language modules
  languageGenerateHooks = concatMapStrings (module: module.generateHooks or "") loadedLanguageModules;

  # Helper function to construct protoc command
  mkProtocCommand = cfg: let
    # Base protoc command
    protocCmd = [
      "${pkgs.protobuf}/bin/protoc"
      "--proto_path=${concatStringsSep " --proto_path=" cfg.protoc.includeDirectories}"
    ];

    # Add language-specific protocol plugins
    protocolPlugins = languageProtocPlugins;

    # Proto files selection
    protoFiles =
      if (cfg.protoc.files != [])
      then cfg.protoc.files
      else if (cfg.protoc.sourceDirectories != [])
      then map (dir: "${dir}/**/*.proto") cfg.protoc.sourceDirectories
      else ["${cfg.root}/**/*.proto"];
  in
    concatStringsSep " " (protocCmd ++ protocolPlugins ++ protoFiles);

  # Create a wrapper script for initialization
  initWrapper = pkgs.writeShellScriptBin "bufrnix_init" ''
        #!/usr/bin/env bash
        set -e

        ${debug.log 1 "Initializing bufrnix project" cfg}

        # Create directory structure
        mkdir -p "${cfg.root}"
        ${debug.log 2 "Created root directory: \"${cfg.root}\"" cfg}

        # Language-specific initialization hooks
        ${languageInitHooks}

        # Create example proto file if none exist
        if [ -z "$(find "${cfg.root}" -name '*.proto' 2>/dev/null)" ]; then
          mkdir -p "${cfg.root}/example/v1"
          cat > "${cfg.root}/example/v1/example.proto" << EOF
    syntax = "proto3";

    package example.v1;

    ${optionalString cfg.languages.go.enable ''
      option go_package = "${cfg.languages.go.packagePrefix}/example/v1;examplev1";
    ''}

    // Example message
    message Example {
      string id = 1;
      string name = 2;
      int32 value = 3;
    }

    // Example service
    service ExampleService {
      rpc GetExample(GetExampleRequest) returns (GetExampleResponse);
    }

    message GetExampleRequest {
      string id = 1;
    }

    message GetExampleResponse {
      Example example = 1;
    }
    EOF
          ${debug.log 2 "Created example proto file: \"${cfg.root}/example/v1/example.proto\"" cfg}
        fi

        # Create buf.yaml for linting
        cat > "${cfg.root}/buf.yaml" << EOF
    version: v1
    name: ${
      if self != null
      then baseNameOf (toString self)
      else "bufrnix"
    }/example
    build:
      roots:
        - ./
    lint:
      use:
        - DEFAULT
    EOF
        ${debug.log 2 "Created buf.yaml: \"${cfg.root}/buf.yaml\"" cfg}

        ${debug.log 1 "Initialization completed successfully" cfg}
        echo "Bufrnix project initialized successfully!"
        echo "Run 'bufrnix_generate' to generate code from proto files."
  '';

  lintWrapper = pkgs.writeShellScriptBin "bufrnix_lint" ''
    #!/usr/bin/env bash
    set -e

    ${debug.log 1 "Starting linting" cfg}

    if ! command -v buf &> /dev/null; then
      echo "Error: 'buf' command not found. Please install buf CLI: https://buf.build/docs/installation"
      exit 1
    fi

    ${debug.printCommand "buf lint \"${cfg.root}\"" cfg}
    ${debug.timeCommand "buf lint \"${cfg.root}\"" cfg}

    ${debug.log 1 "Linting completed successfully" cfg}
  '';
in
  pkgs.writeShellApplication {
    name = "bufrnix";

    runtimeInputs = with pkgs;
      [
        bash
        protobuf
      ]
      ++ languageRuntimeInputs;

    text = ''
      # Language-specific directory creation
      ${languageGenerateHooks}

      ${debug.log 1 "Starting code generation" cfg}

      # Expand proto file globs if needed
      proto_files=""
      ${
        if (cfg.protoc.files == [])
        then
          if (cfg.protoc.sourceDirectories == [])
          then ''
            # Find all proto files from root
            proto_files=$(find "${cfg.root}" -name "*.proto" -type f)
          ''
          else ''
            # Find proto files from specified directories
            ${concatMapStrings (dir: ''
                proto_files="$proto_files $(find "${dir}" -name "*.proto" -type f)"
              '')
              cfg.protoc.sourceDirectories}
          ''
        else ''
          # Use explicitly specified files
          proto_files="${concatStringsSep " " cfg.protoc.files}"
        ''
      }

      # Build the protoc command dynamically using language modules
      protoc_cmd="${pkgs.protobuf}/bin/protoc"
      protoc_args="--proto_path=${concatStringsSep " --proto_path=" cfg.protoc.includeDirectories}"

      # Add language-specific protocol plugins from the loaded modules
      ${concatMapStrings (
          module:
            if module ? protocPlugins
            then ''
              # Add plugin options
              ${concatMapStrings (plugin: ''
                  protoc_args="$protoc_args ${plugin}"
                '')
                module.protocPlugins}
            ''
            else ""
        )
        loadedLanguageModules}

      # Execute protoc with expanded file list
      eval "$protoc_cmd $protoc_args $proto_files"
      ${debug.log 1 "Code generation completed successfully" cfg}
    '';
  }
