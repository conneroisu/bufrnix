{
  description = "Protobuf Compiler/Codegen Declaratively from Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
  };

  outputs = inputs @ {flake-utils, ...}:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};

      scripts = {
        dx = {
          exec = ''$EDITOR $REPO_ROOT/flake.nix'';
          description = "Edit flake.nix";
        };
        lint = {
          exec = ''
            ${pkgs.statix}/bin/statix check $REPO_ROOT/flake.nix
            ${pkgs.deadnix}/bin/deadnix $REPO_ROOT/flake.nix
          '';
          # TODO: Lint other files besides just flake.nix
          description = "Lint flake.nix";
        };
      };

      scriptPackages =
        pkgs.lib.mapAttrs
        (name: script: pkgs.writeShellScriptBin name script.exec)
        scripts;
    in {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          export REPO_ROOT=$(git rev-parse --show-toplevel)
        '';
        packages = with pkgs;
          [
            # Nix
            alejandra
            nixd
            statix
          ]
          ++ builtins.attrValues scriptPackages;
      };
      packages = {
        doc = pkgs.stdenv.mkDerivation {
          pname = "bufrnix-docs";
          version = "0.1";
          src = ./.;
          nativeBuildInputs = with pkgs; [nixdoc mdbook mdbook-open-on-gh mdbook-cmdrun git];
          dontConfigure = true;
          dontFixup = true;
          buildPhase = ''
            runHook preBuild
            cd doc  # Navigate to the doc directory during build
            mkdir -p .git  # Create .git directory
            mdbook build
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            mv book $out
            runHook postInstall
          '';
        };
      } // pkgs.lib.genAttrs (builtins.attrNames scripts) (name: scriptPackages.${name});
    });
}
