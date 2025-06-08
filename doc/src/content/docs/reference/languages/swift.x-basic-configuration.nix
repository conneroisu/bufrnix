{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix = {
      url = "github:conneroisu/bufrnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    bufrnix,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};

      # Create our bufrnix package with Swift language support
      bufrnixPkg = bufrnix.lib.mkBufrnixPackage {
        inherit pkgs;
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
    });
}
