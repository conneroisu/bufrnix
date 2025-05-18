{
  description = "Protobuf Compiler/Codegen Declaratively from Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    nix-unit.url = "github:nix-community/nix-unit";
    nix-unit.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-parts.follows = "flake-parts";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} (
      {self, ...}: {
        systems = import inputs.systems;
        imports = [
          inputs.nix-unit.modules.flake.default
          ./shells/flake-module.nix
          ./doc/flake-module.nix
        ];
        debug = true;
        perSystem = {
          lib,
          self',
          pkgs,
          system,
          ...
        }: {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [];
          };
          nix-unit.tests = {
            "protoc-gen-go-enable" = {
              expr = self.mkBufrnixPackage.go.enable;
              expected = false;
            };
            "protoc-gen-go-package" = {
              expr = self.mkBufrnixPackage.go.package;
              expected = pkgs.protoc-gen-go;
            };
          };

          checks = {};
        };
        flake = {
          # System-agnostic tests can be defined here, and will be picked up by
          # `nix flake check`
          tests.testBar = {
            expr = "bar";
            expected = "bar";
          };
        };
      }
    );
}
