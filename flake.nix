{
  description = "Protobuf Compiler/Codegen Declaratively from Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs: let
    eachSystem = f:
      builtins.listToAttrs (
        map
        (system: {
          name = system;
          value = f system;
        })
        (import inputs.systems)
      );

    # Evaluate the treefmt modules with an inline treefmt config
    treefmtEval = eachSystem (
      system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [];
        };
      in
        inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          # Format Nix files with alejandra
          programs = {
            alejandra.enable = true;

            # Format Markdown, TypeScript, and JSON files with prettier
            buf.enable = true;
            prettier.enable = true;
            prettier.includes = [
              "**/*.md"
              "**/*.mdx"
              "**/*.ts"
              "**/*.tsx"
              "**/*.json"
            ];

            # Format YAML files
            yamlfmt.enable = true;
          };
        }
    );
  in {
    # Flake formatter output for `nix fmt`
    formatter = eachSystem (
      system:
        treefmtEval.${system}.config.build.wrapper
    );

    # Add a check for formatting
    checks = eachSystem (system: {
      formatting = treefmtEval.${system}.config.build.check inputs.self;
    });

    devShells = eachSystem (
      system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
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
              # Add the formatter to the devShell
              treefmtEval.${system}.config.build.wrapper
            ]
            ++ builtins.attrValues scriptPackages;
        };
      }
    );

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
