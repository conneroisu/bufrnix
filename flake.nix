{
  description = "Protobuf Compiler/Codegen from Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
  };

  outputs = inputs @ {flake-utils, ...}:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};

      # Default configuration
      defaultConfig = {
        root = "./proto";
        debug = {
          enable = false;
          verbosity = 1;
          logFile = "";
        };
        protoc = {
          sourceDirectories = ["./proto"];
          includeDirectories = ["./proto"];
          files = [];
        };
        languages = {
          go = {
            enable = false;
            outputPath = "gen/go";
            options = ["paths=source_relative"];
            packagePrefix = "";
            grpc = {
              enable = false;
              options = ["paths=source_relative"];
            };
          };
        };
      };

      # Debug utilities
      debugUtils = {
        log = level: msg: config: let
          shouldLog = config.debug.enable && config.debug.verbosity >= level;
          logPrefix = "[bufrnix] ";
        in
          if shouldLog
          then
            if config.debug.logFile != ""
            then ''
              echo "${logPrefix}${msg}" >> ${config.debug.logFile}
            ''
            else ''
              echo "${logPrefix}${msg}" >&2
            ''
          else "";

        printCommand = cmd: config: let
          shouldPrint = config.debug.enable && config.debug.verbosity >= 2;
        in
          if shouldPrint
          then ''
            echo "[bufrnix] Executing: ${cmd}" >&2
          ''
          else "";

        timeCommand = cmd: config: let
          shouldTime = config.debug.enable && config.debug.verbosity >= 3;
        in
          if shouldTime
          then ''
            echo "[bufrnix] Starting: ${cmd}" >&2
            TIMEFORMAT="[bufrnix] Command took: %3R seconds"
            time (${cmd})
          ''
          else cmd;
      };

      # Function to create a bufrnix package
      mkBufrnixPackage = config: let
        # Merge defaults with user config
        cfg = pkgs.lib.recursiveUpdate defaultConfig config;

        # Helper function to construct protoc command
        mkProtocCommand = cfg: let
          # Base protoc command
          protocCmd = [
            "${pkgs.protobuf}/bin/protoc"
            "--proto_path=${pkgs.lib.concatStringsSep " --proto_path=" cfg.protoc.includeDirectories}"
          ];

          # Go language options
          goOpts = pkgs.lib.optionals cfg.languages.go.enable [
            "--go_out=${cfg.languages.go.outputPath}"
            "--go_opt=${pkgs.lib.concatStringsSep " --go_opt=" cfg.languages.go.options}"
          ];

          # Go gRPC options
          goGrpcOpts = pkgs.lib.optionals (cfg.languages.go.enable && cfg.languages.go.grpc.enable) [
            "--go-grpc_out=${cfg.languages.go.outputPath}"
            "--go-grpc_opt=${pkgs.lib.concatStringsSep " --go-grpc_opt=" cfg.languages.go.grpc.options}"
          ];

          # Proto files selection
          protoFiles =
            if (cfg.protoc.files != [])
            then cfg.protoc.files
            else map (dir: "${dir}/**/*.proto") cfg.protoc.sourceDirectories;
        in
          pkgs.lib.concatStringsSep " " (protocCmd ++ goOpts ++ goGrpcOpts ++ protoFiles);

        # Create wrappers
        generateScript = pkgs.writeTextFile {
          name = "bufrnix-generate";
          executable = true;
          destination = "/bin/bufrnix-generate";
          text = ''
            #!/usr/bin/env bash
            set -e

            ${debugUtils.log 1 "Starting code generation" cfg}
            ${debugUtils.printCommand (mkProtocCommand cfg) cfg}

            # Create output directories
            ${pkgs.lib.optionalString cfg.languages.go.enable ''
              mkdir -p ${cfg.languages.go.outputPath}
              ${debugUtils.log 2 "Created Go output directory: ${cfg.languages.go.outputPath}" cfg}
            ''}

            # Run protoc command
            ${debugUtils.timeCommand (mkProtocCommand cfg) cfg}

            ${debugUtils.log 1 "Code generation completed successfully" cfg}
          '';
        };

        lintScript = pkgs.writeTextFile {
          name = "bufrnix-lint";
          executable = true;
          destination = "/bin/bufrnix-lint";
          text = ''
            #!/usr/bin/env bash
            set -e

            ${debugUtils.log 1 "Starting linting" cfg}

            if ! command -v buf &> /dev/null; then
              echo "Error: 'buf' command not found. Please install buf CLI: https://buf.build/docs/installation"
              exit 1
            fi

            ${debugUtils.printCommand "buf lint ${cfg.root}" cfg}
            ${debugUtils.timeCommand "buf lint ${cfg.root}" cfg}

            ${debugUtils.log 1 "Linting completed successfully" cfg}
          '';
        };

        mainScript = pkgs.writeTextFile {
          name = "bufrnix";
          executable = true;
          destination = "/bin/bufrnix";
          text = ''
            #!/usr/bin/env bash

            if [ $# -eq 0 ]; then
              echo "bufrnix - Nix-powered Protocol Buffer tools"
              echo ""
              echo "Usage: bufrnix COMMAND [ARGS]"
              echo ""
              echo "Available commands:"
              echo "  generate    Generate code from proto files"
              echo "  lint        Lint proto files using buf CLI"
              exit 0
            fi

            COMMAND="$1"
            shift

            case "$COMMAND" in
              generate)
                exec bufrnix-generate "$@"
                ;;
              lint)
                exec bufrnix-lint "$@"
                ;;
              --help|-h|help)
                echo "bufrnix - Nix-powered Protocol Buffer tools"
                echo ""
                echo "Usage: bufrnix COMMAND [ARGS]"
                echo ""
                echo "Available commands:"
                echo "  generate    Generate code from proto files"
                echo "  lint        Lint proto files using buf CLI"
                exit 0
                ;;
              *)
                echo "Error: unknown command '$COMMAND'"
                echo ""
                echo "Usage: bufrnix COMMAND [ARGS]"
                echo ""
                echo "Available commands:"
                echo "  generate    Generate code from proto files"
                echo "  lint        Lint proto files using buf CLI"
                exit 1
                ;;
            esac
          '';
        };
      in
        pkgs.symlinkJoin {
          name = "bufrnix";
          paths =
            [
              mainScript
              generateScript
              lintScript
            ]
            ++ pkgs.lib.optionals cfg.languages.go.enable [
              pkgs.protoc-gen-go
            ]
            ++ pkgs.lib.optionals (cfg.languages.go.enable && cfg.languages.go.grpc.enable) [
              pkgs.protoc-gen-go-grpc
            ];
          buildInputs = with pkgs; [protobuf];
        };
    in {
      packages = {
        default = mkBufrnixPackage {};
        mkBufrnixPackage = mkBufrnixPackage;
      };

      # Simple module
      nixosModules.default = {
        config,
        lib,
        pkgs,
        ...
      }: {
        options.bufrnix = with lib; {
          root = mkOption {
            type = types.str;
            default = "./proto";
            description = "Root directory for proto files";
          };
          languages.go.enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Go code generation";
          };
        };

        config = lib.mkIf (config.bufrnix != {}) {
          environment.systemPackages = [
            (mkBufrnixPackage config.bufrnix)
          ];
        };
      };
    });
}
