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
      openapi = {
        package = pkgs.protoc-gen-openapiv2 or (pkgs.callPackage ../packages/protoc-gen-openapiv2 {});
      };
      python = {
        package = pkgs.protobuf;
        grpc.package = pkgs.python3Packages.grpcio-tools;
        pyi.package = pkgs.protobuf;
        betterproto.package = pkgs.callPackage ../packages/betterproto {};
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

  # Helper function to normalize outputPath from string or array to array
  normalizeOutputPath = path:
    if builtins.isList path
    then path
    else [path];

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

  # Load all enabled language modules for extracting runtime inputs only
  # We need runtime inputs globally, but hooks will be handled per output path
  loadedLanguageModulesForInputs =
    map (
      language:
        if cfg.languages.${language}.enable
        then let
          langCfg = cfg.languages.${language};
          # Normalize to single path for runtime input extraction
          normalizedLangCfg =
            langCfg
            // {
              outputPath =
                if builtins.isList langCfg.outputPath
                then builtins.head langCfg.outputPath
                else langCfg.outputPath;
            };
        in
          import ../languages/${language} {
            inherit pkgs;
            inherit (pkgs) lib;
            config = cfg;
            cfg = normalizedLangCfg;
          }
        else {}
    )
    languageNames;

  # Extract runtime inputs from language modules
  languageRuntimeInputs = concatMap (module: module.runtimeInputs or []) loadedLanguageModulesForInputs;

  # Generate protoc commands for each enabled language with multiple output paths
  generateProtocCommands = let
    enabledLanguages = filter (lang: cfg.languages.${lang}.enable) languageNames;

    # For each enabled language, get the normalized output paths and generate commands
    languageCommands =
      map (
        language: let
          langCfg = cfg.languages.${language};
          module = loadLanguageModule language;
          outputPaths = normalizeOutputPath langCfg.outputPath;

          # Generate a command for each output path
          pathCommands =
            map (
              outputPath: let
                # Create modified cfg with single outputPath for this iteration
                modifiedLangCfg = langCfg // {outputPath = outputPath;};
                modifiedCfg =
                  cfg
                  // {
                    languages =
                      cfg.languages
                      // {
                        ${language} = modifiedLangCfg;
                      };
                  };

                # Load module with modified config
                modifiedModule = import ../languages/${language} {
                  inherit pkgs;
                  inherit (pkgs) lib;
                  config = modifiedCfg;
                  cfg = modifiedLangCfg;
                };
              in {
                inherit outputPath;
                runtimeInputs = modifiedModule.runtimeInputs or [];
                protocPlugins = modifiedModule.protocPlugins or [];
                initHooks = modifiedModule.initHooks or "";
                generateHooks = modifiedModule.generateHooks or "";
              }
            )
            outputPaths;
        in {
          inherit language;
          commands = pathCommands;
        }
      )
      enabledLanguages;
  in
    languageCommands;
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
      ${debug.log 1 "Starting code generation with multiple output paths support" cfg}

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

      protoc_cmd="${pkgs.protobuf}/bin/protoc"
      base_protoc_args="-I ${concatStringsSep " -I " cfg.protoc.includeDirectories}"

      # Handle nanopb options files if nanopb is enabled
      nanopb_opts=""
      ${optionalString (cfg.languages.c.enable && cfg.languages.c.nanopb.enable) ''
        # Find nanopb options files and add them to protoc_args
        options_file=$(find . -name "*.options" -type f 2>/dev/null | head -1)
        if [ -n "$options_file" ]; then
          echo "Found nanopb options file: $options_file"
          nanopb_opts="--nanopb_opt=-f$options_file"
        fi
      ''}

      # Generate protoc commands for each unique output path combination
      ${concatMapStrings (
          langCmd:
            concatMapStrings (pathCmd: ''
              echo "Generating ${langCmd.language} code for output path: ${pathCmd.outputPath}"

              # Run initialization hooks for this path
              ${pathCmd.initHooks}

              # Create directory for this output path
              mkdir -p "${pathCmd.outputPath}"

              # Build protoc command for this specific output path
              protoc_args="$base_protoc_args $nanopb_opts"
              ${concatMapStrings (plugin: ''
                  protoc_args="$protoc_args ${plugin}"
                '')
                pathCmd.protocPlugins}

              # Execute protoc for this output path
              eval "$protoc_cmd $protoc_args $proto_files"

              # Run generation hooks for this path
              ${pathCmd.generateHooks}

            '')
            langCmd.commands
        )
        generateProtocCommands}

      ${debug.log 1 "Multiple output path code generation completed successfully" cfg}
    '';
  }
