{
  description = "Protobuf Compiler/Codegen Declaratively from Nix";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "https://flakehub.com/f/hercules-ci/flake-parts/0.1.*";
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
            "test integer equality is reflexive" = {
              expr = "123";
              expected = "123";
            };
            "frobnicator" = {
              "testFoo" = {
                expr = "foo";
                expected = "foo";
              };
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
