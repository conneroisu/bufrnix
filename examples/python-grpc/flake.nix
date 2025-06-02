{
  description = "Python with gRPC example";

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
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python3
          python3Packages.protobuf
          python3Packages.grpcio
          python3Packages.grpcio-tools
          protobuf
        ];

        shellHook = ''
          echo "Python gRPC Example"
          echo "=================="
          echo "Commands:"
          echo "  nix build - Generate Python + gRPC code"
          echo "  python server.py - Run gRPC server"
          echo "  python client.py - Run gRPC client"
          echo ""
        '';
      };
      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;

          config = {
            root = ./.;
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
            };

            # Python with gRPC support
            languages.python = {
              enable = true;
              outputPath = "proto/gen/python";

              grpc = {
                enable = true;
              };
            };
          };
        };
      };
    });
}
