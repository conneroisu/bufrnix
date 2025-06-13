{
  description = "Python flake-parts example";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.url = "path:../..";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    bufrnix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      perSystem = {pkgs, ...}: {
        packages.default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;
          config = {
            root = ./.;
            protoc = {
              includeDirectories = ["proto"];
              files = ["proto/greeter.proto"];
            };
            languages.python = {
              enable = true;
              outputPath = "proto/gen/python";
              grpc.enable = true;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            python3
            python3Packages.grpcio
            python3Packages.protobuf
            protobuf
          ];
          shellHook = ''
            echo "Python flake-parts example"
            echo "Run 'nix build' to generate code"
          '';
        };
      };
    };
}
