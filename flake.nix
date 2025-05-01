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

      # Import all modules
      bufrnixOptions = import ./src/lib/bufrnix-options.nix {inherit (pkgs) lib;};
      bufrnixDebug = import ./src/lib/utils/debug.nix {inherit (pkgs) lib;};

      # Create the mkBufrnixPackage function
      mkBufrnixPackage = config: let
        # Merge defaults with user config
        cfg = pkgs.lib.recursiveUpdate bufrnixOptions.options config;

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

          ${bufrnixDebug.log 1 "Starting code generation" cfg}
          ${bufrnixDebug.printCommand (mkProtocCommand cfg) cfg}

          # Create output directories
          ${pkgs.lib.optionalString cfg.languages.go.enable ''
            mkdir -p ${cfg.languages.go.outputPath}
            ${bufrnixDebug.log 2 "Created Go output directory: ${cfg.languages.go.outputPath}" cfg}
          ''}

          # Run protoc command
          ${bufrnixDebug.timeCommand (mkProtocCommand cfg) cfg}

          ${bufrnixDebug.log 1 "Code generation completed successfully" cfg}
        '';

        # Create a wrapper script for initialization
        initWrapper = pkgs.writeShellScriptBin "bufrnix_init" ''
                      #!/usr/bin/env bash
                      set -e

                      ${bufrnixDebug.log 1 "Initializing bufrnix project" cfg}

                      # Create directory structure
                      mkdir -p ${cfg.root}
                      ${bufrnixDebug.log 2 "Created root directory: ${cfg.root}" cfg}

                      # Create example proto file if none exist
                      if [ -z "$(find ${cfg.root} -name '*.proto' 2>/dev/null)" ]; then
                        mkdir -p ${cfg.root}/example/v1
                        cat > ${cfg.root}/example/v1/example.proto << EOF
          syntax = "proto3";

          package example.v1;

          ${pkgs.lib.optionalString cfg.languages.go.enable ''
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
                        ${bufrnixDebug.log 2 "Created example proto file: ${cfg.root}/example/v1/example.proto" cfg}
                      fi

                      # Create buf.yaml for linting
                      cat > ${cfg.root}/buf.yaml << EOF
          version: v1
          name: ${
            if inputs.self != null
            then pkgs.lib.baseNameOf (toString inputs.self)
            else "bufrnix"
          }/example
          build:
            roots:
              - ./
          lint:
            use:
              - DEFAULT
          EOF
                      ${bufrnixDebug.log 2 "Created buf.yaml: ${cfg.root}/buf.yaml" cfg}

                      ${bufrnixDebug.log 1 "Initialization completed successfully" cfg}
                      echo "Bufrnix project initialized successfully!"
                      echo "Run 'bufrnix_generate' to generate code from proto files."
        '';

        # Create a wrapper script for linting
        lintWrapper = pkgs.writeShellScriptBin "bufrnix_lint" ''
          #!/usr/bin/env bash
          set -e

          ${bufrnixDebug.log 1 "Starting linting" cfg}

          if ! command -v buf &> /dev/null; then
            echo "Error: 'buf' command not found. Please install buf CLI: https://buf.build/docs/installation"
            exit 1
          fi

          ${bufrnixDebug.printCommand "buf lint ${cfg.root}" cfg}
          ${bufrnixDebug.timeCommand "buf lint ${cfg.root}" cfg}

          ${bufrnixDebug.log 1 "Linting completed successfully" cfg}
        '';
      in
        pkgs.symlinkJoin {
          name = "bufrnix";
          paths = [
            protocWrapper
            initWrapper
            lintWrapper
          ];
          buildInputs = with pkgs;
            [
              protobuf
            ]
            ++ pkgs.lib.optionals cfg.languages.go.enable [
              protoc-gen-go
            ]
            ++ pkgs.lib.optionals (cfg.languages.go.enable && cfg.languages.go.grpc.enable) [
              protoc-gen-go-grpc
            ];
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
      nixosModules.default = import ./src/module.nix;

      # Expose as library for more flexibility
      lib = {
        bufrnixOptions = import ./src/lib/bufrnix-options.nix {lib = pkgs.lib;};
        bufrnixDebug = import ./src/lib/utils/debug.nix {lib = pkgs.lib;};
        mkBufrnixPackage = mkBufrnixPackage;
      };
    });
}
