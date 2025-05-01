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

      # Create the main package
      mkBufrnixPackage = {
        root ? "./proto",
        languages ? {},
        debug ? {},
      }: let
        # Default values
        goEnabled = languages.go.enable or false;
        goGrpcEnabled = (languages.go.grpc.enable or false) && goEnabled;
        goOutputPath = languages.go.outputPath or "gen/go";
        goOptions = languages.go.options or ["paths=source_relative"];
        goGrpcOptions = languages.go.grpc.options or ["paths=source_relative"];

        # Create protoc command
        mkProtocCmd = let
          baseCmd = "${pkgs.protobuf}/bin/protoc --proto_path=${root}";
          goFlags =
            if goEnabled
            then "--go_out=${goOutputPath} --go_opt=${pkgs.lib.concatStringsSep " --go_opt=" goOptions}"
            else "";
          goGrpcFlags =
            if goGrpcEnabled
            then "--go-grpc_out=${goOutputPath} --go-grpc_opt=${pkgs.lib.concatStringsSep " --go-grpc_opt=" goGrpcOptions}"
            else "";
          protoFiles = "${root}/**/*.proto";
        in "${baseCmd} ${goFlags} ${goGrpcFlags} ${protoFiles}";

        # Create the main executable
        mainScript = pkgs.writeShellScriptBin "bufrnix" ''
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

          case "$1" in
            generate)
              shift
              exec bufrnix-generate "$@"
              ;;
            lint)
              shift
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
              echo "Error: unknown command '$1'"
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

        # Create the generate script
        generateScript = pkgs.writeShellScriptBin "bufrnix-generate" ''
          #!/usr/bin/env bash
          set -e

          echo "[bufrnix] Starting code generation"

          # Create output directories
          ${
            if goEnabled
            then "mkdir -p ${goOutputPath}"
            else ""
          }

          # Run protoc command
          echo "[bufrnix] Running: ${mkProtocCmd}"
          ${mkProtocCmd}

          echo "[bufrnix] Code generation completed successfully"
        '';

        # Create the lint script
        lintScript = pkgs.writeShellScriptBin "bufrnix-lint" ''
          #!/usr/bin/env bash
          set -e

          echo "[bufrnix] Starting linting"

          if ! command -v buf &> /dev/null; then
            echo "Error: 'buf' command not found. Please install buf CLI: https://buf.build/docs/installation"
            exit 1
          fi

          echo "[bufrnix] Running: buf lint ${root}"
          buf lint ${root}

          echo "[bufrnix] Linting completed successfully"
        '';

        # Additional dependencies based on config
        extraDeps = with pkgs;
          []
          ++ (
            if goEnabled
            then [protoc-gen-go]
            else []
          )
          ++ (
            if goGrpcEnabled
            then [protoc-gen-go-grpc]
            else []
          );
      in
        pkgs.symlinkJoin {
          name = "bufrnix";
          paths =
            [
              mainScript
              generateScript
              lintScript
            ]
            ++ extraDeps;
          buildInputs = [pkgs.protobuf];
        };
    in {
      # Package exports
      packages = {
        default = mkBufrnixPackage {};
        mkBufrnixPackage = mkBufrnixPackage;
      };

      # Simple development shell
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          (mkBufrnixPackage {})
          buf
          protobuf
        ];
      };
    });
}
