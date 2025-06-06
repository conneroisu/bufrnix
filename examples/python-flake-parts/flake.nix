{
  description = "Python flake-parts example with Bufrnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.url = "path:../..";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages = {
          # Generate Python protobuf code using Bufrnix
          default = inputs.bufrnix.lib.mkBufrnixPackage {
            inherit pkgs;
            config = {
              root = ./.;
              protoc = {
                sourceDirectories = [ "./proto" ];
                includeDirectories = [ "./proto" ];
                files = [ "./proto/example/v1/user.proto" ];
              };
              languages = {
                python = {
                  enable = true;
                  outputPath = "gen";
                  grpc.enable = true;
                };
              };
              debug = {
                enable = true;
                verbosity = 1;
              };
            };
          };
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            python3Packages.protobuf
            python3Packages.grpcio
            python3Packages.grpcio-tools
            protobuf
          ];
          
          shellHook = ''
            echo "🐍 Python flake-parts Bufrnix development environment"
            echo "📦 Available commands:"
            echo "  nix build               - Generate protobuf code"
            echo "  python src/main.py      - Run the example application"
            echo ""
          '';
        };
      };
    };
}