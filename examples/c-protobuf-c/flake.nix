{
  description = "C protobuf-c example for bufrnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "path:../..";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
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
          pkgs.nixd
          pkgs.alejandra
          pkgs.gcc
          pkgs.cmake
          pkgs.pkg-config
          pkgs.protobuf
          pkgs.protobufc
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
              files = ["./proto/example/v1/example.proto"];
            };
            languages.c = {
              enable = true;
              outputPath = "proto/gen/c";
              protobuf-c = {
                enable = true;
                options = [];
              };
            };
          };
        };
      };
    });
}
