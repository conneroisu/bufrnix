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

  /* Extract default values from option definitions recursively.
  
     This function traverses option definitions and extracts their default values,
     handling both simple options and nested attribute sets of options.
     
     Type: extractDefaults :: AttrSet -> AttrSet
     
     Example:
       extractDefaults { 
         foo.default = "bar"; 
         nested = { baz.default = 42; }; 
       }
       => { foo = "bar"; nested = { baz = 42; }; }
  */
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
    breaking = {
      buf = {
        package = pkgs.buf;
      };
    };
  };

  # Merge defaults with user config
  cfg = recursiveUpdate (recursiveUpdate defaultConfig packageDefaults) config;

  /* Normalize output path from string or array to consistent array format.
  
     Bufrnix supports both single output paths (as strings) and multiple output paths
     (as arrays) for each language. This function ensures all paths are represented
     as arrays for consistent processing.
     
     Type: normalizeOutputPath :: (String | [String]) -> [String]
     
     Example:
       normalizeOutputPath "gen/go" => ["gen/go"]
       normalizeOutputPath ["gen/go", "pkg/proto"] => ["gen/go", "pkg/proto"]
  */
  normalizeOutputPath = path:
    if builtins.isList path
    then path
    else [path];

  # Load language modules based on configuration
  languageNames = attrNames cfg.languages;

  /* Load a language module if enabled in the configuration.
  
     Conditionally imports and instantiates a language module based on whether
     the language is enabled in the configuration. Language modules provide
     protoc plugins, runtime inputs, and generation hooks.
     
     Type: loadLanguageModule :: String -> AttrSet
     
     Example:
       loadLanguageModule "go" 
       => { runtimeInputs = [protoc-gen-go]; protocPlugins = ["--go_out=."]; ... }
  */
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

  /* Generate protoc commands for each enabled language with multiple output paths.
  
     This function creates the command structure for protoc code generation across
     all enabled languages and their configured output paths. It handles multi-output
     scenarios where a single language can generate code to multiple directories.
     
     Returns a list of language command objects, each containing:
     - language: The language name
     - commands: List of path-specific command objects with:
       * outputPath: Target directory for generated code
       * runtimeInputs: Required packages for generation
       * protocPlugins: protoc command-line plugin arguments
       * initHooks: Shell commands run before generation
       * generateHooks: Shell commands run after generation
     
     Type: generateProtocCommands :: [{ language :: String; commands :: [Command]; }]
  */
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
      ++ languageRuntimeInputs
      ++ optionals cfg.breaking.enable [
        cfg.breaking.buf.package
        git  # Required for git-based breaking change detection
      ];

    text = ''
      ${debug.log 1 "Starting code generation with multiple output paths support" cfg}

      ${optionalString cfg.breaking.enable ''
        # Breaking Change Detection
        echo "Running breaking change detection..."
        
        ${debug.log 2 "Breaking change detection enabled with mode: ${cfg.breaking.mode}" cfg}
        
        # Check if we're in a git repository
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
          ${if cfg.breaking.failOnBreaking then ''
            echo "ERROR: Breaking change detection requires a git repository, but none found"
            exit 1
          '' else ''
            echo "WARNING: Breaking change detection requires a git repository, but none found. Skipping..."
          ''}
        else
          # Verify base reference exists
          if ! git rev-parse --verify "${cfg.breaking.baseReference}" > /dev/null 2>&1; then
            ${if cfg.breaking.failOnBreaking then ''
              echo "ERROR: Base reference '${cfg.breaking.baseReference}' not found in git repository"
              exit 1
            '' else ''
              echo "WARNING: Base reference '${cfg.breaking.baseReference}' not found. Skipping breaking change detection..."
            ''}
          else
            # Build buf breaking command
            buf_cmd="${cfg.breaking.buf.package}/bin/buf breaking"
            
            # Add mode flag
            case "${cfg.breaking.mode}" in
              "backward")
                buf_cmd="$buf_cmd --against-input-config"
                ;;
              "forward")
                buf_cmd="$buf_cmd --against-input-config" 
                ;;
              "full")
                buf_cmd="$buf_cmd --against-input-config"
                ;;
            esac
            
            # Add base reference
            buf_cmd="$buf_cmd '.git#branch=${cfg.breaking.baseReference}'"
            
            # Add config file if specified
            ${optionalString (cfg.breaking.buf.configPath != null) ''
              buf_cmd="$buf_cmd --config '${cfg.breaking.buf.configPath}'"
            ''}
            
            # Add output format
            case "${cfg.breaking.outputFormat}" in
              "json")
                buf_cmd="$buf_cmd --format json"
                ;;
              "junit")
                buf_cmd="$buf_cmd --format junit"
                ;;
              *)
                # Default to text format
                ;;
            esac
            
            # Add ignore rules
            ${concatMapStrings (rule: ''
              buf_cmd="$buf_cmd --except-rule ${rule}"
            '') cfg.breaking.ignoreRules}
            
            ${debug.log 3 "Running buf breaking command: $buf_cmd" cfg}
            
            # Execute buf breaking command with timeout
            if timeout ${toString cfg.breaking.buf.timeout} bash -c "$buf_cmd"; then
              echo "✓ No breaking changes detected"
            else
              exit_code=$?
              if [ $exit_code -eq 124 ]; then
                echo "ERROR: Breaking change detection timed out after ${toString cfg.breaking.buf.timeout} seconds"
                ${if cfg.breaking.failOnBreaking then "exit 1" else "echo 'WARNING: Continuing despite timeout...'"}
              elif [ $exit_code -ne 0 ]; then
                echo "⚠ Breaking changes detected!"
                ${if cfg.breaking.failOnBreaking then ''
                  echo "ERROR: Breaking changes found. Set breaking.failOnBreaking = false to continue anyway."
                  exit 1
                '' else ''
                  echo "WARNING: Breaking changes found but failOnBreaking is disabled. Continuing..."
                ''}
              fi
            fi
          fi
        fi
        
        echo "Breaking change detection completed."
      ''}

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
