{
  description = "Swift protobuf example using bufrnix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "path:../..";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    bufrnix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
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
        packages.default = bufrnixPkg;

        devShells.default = pkgs.mkShell {
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
      }
    );
}
