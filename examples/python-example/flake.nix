{
  description = "Python example using bufrnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "path:../..";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    bufrnix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Development shell with Python and generated code
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Python environment
          python3
          python3Packages.grpcio
          python3Packages.grpcio-tools
          python3Packages.protobuf
          python3Packages.mypy
          python3Packages.black
          python3Packages.pytest

          # Development tools
          buf
          protobuf
        ];

        shellHook = ''
          echo "Python Bufrnix Example"
          echo "====================="
          echo ""
          echo "Available commands:"
          echo "  nix build       - Generate Python protobuf code"
          echo "  python main.py  - Run the example Python client"
          echo "  pytest          - Run tests"
          echo ""
          echo "Python code will be generated in: proto/gen/python/"
          echo ""
        '';
      };

      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;

          config = {
            # Basic configuration
            root = ./.;
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
            };

            # Python language configuration
            languages.python = {
              enable = true;
              outputPath = "proto/gen/python";

              # Enable gRPC support
              grpc = {
                enable = true;
              };

              # Enable mypy stubs for type checking
              mypy = {
                enable = true;
              };
            };
          };
        };
      };
    });
}
