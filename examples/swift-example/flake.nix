{
  description = "Swift protobuf example using bufrnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "../..";
  };

  outputs = {
    self,
    nixpkgs,
    bufrnix,
  }: let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {inherit system;};

    # Create our bufrnix package with Swift language support
    bufrnixPkg = bufrnix.lib.mkBufrnixPackage {
      inherit pkgs;
      inherit (pkgs) lib;
      config = {
        languages = {
          swift = {
            enable = true;
            outputPath = "proto/gen/swift";
          };
        };
      };
    };
  in {
    packages.${system}.default = bufrnixPkg;

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        bufrnixPkg
        swift
        protoc-gen-swift
      ];

      shellHook = ''
        echo "Swift protobuf example development environment"
        echo "Available commands:"
        echo "  bufrnix_init    - Initialize proto structure"
        echo "  bufrnix         - Generate Swift code from proto files"
        echo "  bufrnix_lint    - Lint proto files"
      '';
    };
  };
}
