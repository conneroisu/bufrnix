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
        debug = true;
        systems = import inputs.systems;
        imports = [
          inputs.nix-unit.modules.flake.default
          ./doc/flake-module.nix
        ];
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
            "simple-test" = {
              expr = "foo";
              expected = "foo";
            };
          };

          devShells = let
            scripts = {
              dx = {
                exec = ''$EDITOR $REPO_ROOT/flake.nix'';
                description = "Edit flake.nix";
              };
              lint = {
                exec = ''
                  REPO_ROOT=$(git rev-parse --show-toplevel)
                  ${pkgs.statix}/bin/statix check $REPO_ROOT/flake.nix
                  ${pkgs.deadnix}/bin/deadnix $REPO_ROOT/flake.nix
                '';
                description = "Lint flake.nix";
              };
            };

            scriptPackages =
              pkgs.lib.mapAttrs
              (name: script: pkgs.writeShellScriptBin name script.exec)
              scripts;
          in {
            default = pkgs.mkShell {
              shellHook = ''
                export REPO_ROOT=$(git rev-parse --show-toplevel)
              '';
              packages = with pkgs;
                [
                  # Nix
                  alejandra
                  nixd
                  statix
                  # Docs
                  astro-language-server
                  markdownlint-cli
                  bun
                ]
                ++ builtins.attrValues scriptPackages;
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

          # Export the constructor function at the flake level
          lib = {
            mkBufrnixPackage = {
              lib,
              pkgs,
              self ? null,
              config ? {},
            }:
              import "${inputs.self}/src/lib/mkBufrnix.nix" {
                inherit lib pkgs self config;
              };
          };
        };
      }
    );
}
