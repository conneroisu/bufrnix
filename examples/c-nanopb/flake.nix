{
  description = "C nanopb example for bufrnix - embedded systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.url = "path:../..";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    bufrnix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.gcc
          pkgs.cmake
          pkgs.pkg-config
          pkgs.nanopb
          pkgs.protobuf
        ];
      };

      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;
          config = {
            root = ./.;
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
              files = ["./proto/example/v1/sensor.proto"];
            };
            languages.c = {
              enable = true;
              outputPath = "proto/gen/c";
              nanopb = {
                enable = true;
                options = [];
                # Nanopb-specific configuration
                maxSize = 256; # Default max size for dynamic allocations
                fixedLength = true; # Use fixed-length arrays where possible
                noUnions = false; # Allow unions (oneof fields)
              };
            };
          };
        };
      };
    });
}
