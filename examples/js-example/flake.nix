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
            languages.js = {
              enable = true;
              outputPath = "proto/gen/js";
              packageName = "example-proto";
              # Modern JavaScript with ECMAScript modules
              es = {
                enable = true;
              };
              # Modern RPC with Connect-ES
              connect = {
                enable = true;
              };
              # Browser-compatible RPC with gRPC-Web
              grpcWeb = {
                enable = true;
              };
            };
          };
        };
      };
    });
}