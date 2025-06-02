{
  description = "Struct transformer example for bufrnix - generates transformation functions between protobuf and business logic structs";

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
          pkgs.go
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
              files = ["./proto/example/v1/product.proto"];
            };
            languages.go = {
              enable = true;
              outputPath = "gen/go";
              structTransformer = {
                enable = true;
                goRepoPackage = "models";
                goProtobufPackage = "proto";
                goModelsFilePath = "models/models.go";
                outputPackage = "transform";
              };
            };
          };
        };
      };
    });
}
