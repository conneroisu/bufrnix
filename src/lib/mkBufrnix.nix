{
  pkgs,
  self ? null,
  config ? {},
  ...
}:
with pkgs.lib; let
  # Import our modules
  optionsDef = import ./bufrnix-options.nix {inherit (pkgs) lib;};
  debug = import ./utils/debug.nix {inherit (pkgs) lib;};

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
        protovalidate.package = pkgs.protovalidate-go or null; # Not yet in nixpkgs
        openapiv2.package = pkgs.protoc-gen-openapiv2 or (pkgs.callPackage ../packages/protoc-gen-openapiv2 {});
        vtprotobuf.package = pkgs.protoc-gen-go-vtproto or (pkgs.callPackage ../packages/protoc-gen-go-vtproto {});
        json.package = pkgs.protoc-gen-go-json or (pkgs.callPackage ../packages/protoc-gen-go-json {});
        federation.package = pkgs.protoc-gen-grpc-federation or null; # Not yet in nixpkgs
        structTransformer.package = pkgs.protoc-gen-struct-transformer or (pkgs.callPackage ../languages/go/protoc-gen-struct-transformer.nix {});
      };
      php = {
        package = pkgs.protobuf;
        twirp.package = pkgs.protoc-gen-twirp_php;
      };
      js = {
        package = jsPackage;
        es.package = pkgs.protoc-gen-es;
        connect.package = pkgs.protoc-gen-connect-es;
        grpcWeb.package = pkgs.protoc-gen-grpc-web;
        twirp.package = pkgs.protoc-gen-twirp_js;
      };
      dart = {
        package = pkgs.protoc-gen-dart;
        grpc.package = pkgs.protoc-gen-dart;
      };
      doc = {
        package = pkgs.protoc-gen-doc;
      };
      python = {
        package = pkgs.protobuf;
        grpc.package = pkgs.python3Packages.grpcio-tools;
        pyi.package = pkgs.protobuf;
        betterproto.package = pkgs.callPackage ../languages/python/betterproto-package.nix {};
        mypy.package = pkgs.python3Packages.mypy-protobuf;
      };
      swift = {
        package = pkgs.protoc-gen-swift;
      };
      c = {
        protobuf-c.package = pkgs.protobufc;
        nanopb.package = pkgs.nanopb;
      };
      csharp = {
        sdk = pkgs.dotnetCorePackages.sdk_8_0;
      };
      java = {
        package = pkgs.protobuf;
        jdk = pkgs.jdk17;
        grpc.package = pkgs.callPackage ../packages/grpc-java {};
        protovalidate.package = pkgs.callPackage ../packages/protoc-gen-validate-java {};
      };
      kotlin = {
        jdk = pkgs.jdk17;
      };
      cpp = {
        package = pkgs.protobuf;
        grpc.package = pkgs.grpc;
        nanopb.package = pkgs.nanopb;
        protobuf-c.package = pkgs.protobufc;
      };
      svg = {
        package = pkgs.protoc-gen-d2 or null; # Will need to be provided by user until in nixpkgs
      };
      scala = {
        package = pkgs.callPackage ../packages/scalapb {};
      };
    };
  };

  # Merge defaults with user config
  cfg = recursiveUpdate (recursiveUpdate defaultConfig packageDefaults) config;

  # Load language modules based on configuration
  languageNames = attrNames cfg.languages;

  # Function to load a language module if enabled
  loadLanguageModule = language:
    if cfg.languages.${language}.enable
    then
      import ../languages/${language}
      {
        inherit pkgs;
        inherit (pkgs) lib;
        config = cfg;
        cfg = cfg.languages.${language};
      }
    else {};

  # Load all enabled language modules
  loadedLanguageModules = map loadLanguageModule languageNames;

  # Extract runtime inputs from language modules
  languageRuntimeInputs = concatMap (module: module.runtimeInputs or []) loadedLanguageModules;

  # Extract initialization hooks from language modules
  languageInitHooks = concatMapStrings (module: module.initHooks or "") loadedLanguageModules;

  # Extract code generation hooks from language modules
  languageGenerateHooks = concatMapStrings (module: module.generateHooks or "") loadedLanguageModules;
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
      # Language-specific initialization
      ${languageInitHooks}

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

      # Handle nanopb options files if nanopb is enabled
      ${optionalString (cfg.languages.c.enable && cfg.languages.c.nanopb.enable) ''
        # Find nanopb options files and add them to protoc_args
        options_file=$(find . -name "*.options" -type f 2>/dev/null | head -1)
        if [ -n "$options_file" ]; then
          echo "Found nanopb options file: $options_file"
          protoc_args="$protoc_args --nanopb_opt=-f$options_file"
        fi
      ''}

      # Execute protoc with expanded file list
      eval "$protoc_cmd $protoc_args $proto_files"
      ${debug.log 1 "Code generation completed successfully" cfg}
    '';
  }
