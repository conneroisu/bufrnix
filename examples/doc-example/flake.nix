{
  description = "JavaScript example for bufrnix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
        packages = [
          pkgs.nodejs
          pkgs.nodePackages.typescript
        ];
      };
      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit (pkgs) lib;
          inherit pkgs;
          config = {
            root = ./.;
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
              files = ["./proto/example/v1/example.proto"];
            };
            languages.doc = {
              enable = true;
              outputPath = "proto/gen/doc";
            };
          };
        };
      };
    });
}
