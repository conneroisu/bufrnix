{
  description = "Simple bufrnix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "github:conneroisu/bufrnix";
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
      packages = {
        bufrnix = bufrnix.packages.${system}.mkBufrnixPackage {
          inherit self;
          root = "./proto";
          go = {
            protoc-gen-go = {
              enable = true;
            };
          };
        };
      };
    });
}
