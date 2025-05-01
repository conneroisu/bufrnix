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

      # Define all our configurations and utilities inline to avoid import issues

      # Debug utilities
      debugUtils = {
        # Debug logging function
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

        # Function to print commands being executed
        printCommand = cmd: config: let
          shouldPrint = config.debug.enable && config.debug.verbosity >= 2;
        in
          if shouldPrint
          then ''
            echo "[bufrnix] Executing: ${cmd}" >&2
          ''
          else "";

        # Function to time command execution
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

      # Configuration options
      bufrnixOptionsModule = with pkgs.lib; {
        options = {
          # Basic configuration
          root = mkOption {
            type = types.str;
            default = "./proto";
            description = "Root directory for proto files";
          };

          # Debug options
          debug = {
            enable = mkOption {
              type = types.bool;
              default = false;
              description = "Enable debug mode";
            };

            verbosity = mkOption {
              type = types.int;
              default = 1;
              description = "Debug verbosity level (1-3)";
            };

            logFile = mkOption {
              type = types.str;
              default = "";
              description = "Path to debug log file. If empty, logs to stdout";
            };
          };

          # protoc options
          protoc = {
            sourceDirectories = mkOption {
              type = types.listOf types.str;
              default = ["./proto"];
              description = "Directories containing proto files to compile";
            };

            includeDirectories = mkOption {
              type = types.listOf types.str;
              default = ["./proto"];
              description = "Directories to include in the include path";
            };

            files = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Specific proto files to compile (leave empty to compile all)";
            };
          };

          # Language options
          languages = {
            go = {
              enable = mkOption {
                type = types.bool;
                default = false;
                description = "Enable Go code generation";
              };

              outputPath = mkOption {
                type = types.str;
                default = "gen/go";
                description = "Output directory for generated Go code";
              };

              options = mkOption {
                type = types.listOf types.str;
                default = ["paths=source_relative"];
                description = "Options to pass to protoc-gen-go";
              };

              packagePrefix = mkOption {
                type = types.str;
                default = "";
                description = "Go package prefix for generated code";
              };

              grpc = {
                enable = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Enable gRPC code generation for Go";
                };

                options = mkOption {
                  type = types.listOf types.str;
                  default = ["paths=source_relative"];
                  description = "Options to pass to protoc-gen-go-grpc";
                };
              };
            };
          };
        };
      };

      # Function to create a bufrnix package
      mkBufrnixPackage = config: let
        # Merge defaults with user config
        cfg = pkgs.lib.recursiveUpdate bufrnixOptionsModule.options config;

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

        # Create a wrapper script for the protoc command
        protocWrapper = pkgs.writeShellScriptBin "bufrnix_generate" ''
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

        # Initialization functionality removed as requested

        # Create a wrapper script for linting
        lintWrapper = pkgs.writeShellScriptBin "bufrnix_lint" ''
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

        # Build the dependencies list
        buildInputsList = with pkgs;
          [
            protobuf
          ]
          ++ pkgs.lib.optionals cfg.languages.go.enable [
            protoc-gen-go
          ]
          ++ pkgs.lib.optionals (cfg.languages.go.enable && cfg.languages.go.grpc.enable) [
            protoc-gen-go-grpc
          ];
      in
        pkgs.symlinkJoin {
          name = "bufrnix";
          paths = [
            protocWrapper
            lintWrapper
          ];
          buildInputs = buildInputsList;
        };

      # NixOS module definition
      nixosModule = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.bufrnix;
      in {
        options.bufrnix = bufrnixOptionsModule.options;

        config = lib.mkIf (cfg != {}) {
          environment.systemPackages = [
            (mkBufrnixPackage cfg)
          ];
        };
      };

      scripts = {
        dx = {
          exec = ''$EDITOR $REPO_ROOT/flake.nix'';
          description = "Edit flake.nix";
        };
        lint = {
          exec = ''
            ${pkgs.statix}/bin/statix check $REPO_ROOT/flake.nix
            ${pkgs.deadnix}/bin/deadnix $REPO_ROOT/flake.nix
          '';
          description = "Lint flake.nix";
        };
        format = {
          exec = ''
            ${pkgs.alejandra}/bin/alejandra $REPO_ROOT/flake.nix
          '';
          description = "Format flake.nix";
        };
      };

      scriptPackages =
        pkgs.lib.mapAttrs
        (name: script: pkgs.writeShellScriptBin name script.exec)
        scripts;
    in {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          export REPO_ROOT=$(git rev-parse --show-toplevel)
        '';
        packages = with pkgs;
          [
            # Nix
            alejandra
            nixd
            statix
            deadnix
            # Protobuf tools
            protobuf
            buf
          ]
          ++ builtins.attrValues scriptPackages;
      };

      # Export our bufrnix package functions and modules
      packages = {
        default = mkBufrnixPackage {};
        mkBufrnixPackage = mkBufrnixPackage;

        doc = pkgs.stdenv.mkDerivation {
          pname = "bufrnix-docs";
          version = "0.1";
          src = ./.;
          nativeBuildInputs = with pkgs; [nixdoc mdbook mdbook-open-on-gh mdbook-cmdrun git];
          dontConfigure = true;
          dontFixup = true;
          buildPhase = ''
            runHook preBuild
            cd doc  # Navigate to the doc directory during build
            mkdir -p .git  # Create .git directory
            mdbook build
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            mv book $out
            runHook postInstall
          '';
        };
      };

      # Export NixOS module
      nixosModules.default = nixosModule;

      # Expose as library for more flexibility
      lib = {
        bufrnixOptions = bufrnixOptionsModule.options;
        bufrnixDebug = debugUtils;
        mkBufrnixPackage = mkBufrnixPackage;
      };
    });
}
