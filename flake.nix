{
  description = "Protobuf Compiler/Codegen Declaratively from Nix";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };
  outputs = inputs: let
    eachSystem = f:
      builtins.listToAttrs (
        map (system: {
          name = system;
          value = f system;
        })
        (import inputs.systems)
      );
  in {
    devShells = eachSystem (
      system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [];
        };
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
      }
    );
    checks = eachSystem (system: {});
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
