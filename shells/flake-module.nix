{
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    lib,
    system,
    ...
  }: let
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
        # TODO: Lint other files besides just flake.nix
        description = "Lint flake.nix";
      };
      tests = {
        exec = ''
          REPO_ROOT=$(git rev-parse --show-toplevel)
          EPATH="$REPO_ROOT"/examples/simple-flake/
          echo "validating simple-flake example @ $EPATH"
          cd $EPATH
          nix run .\#packages.${system}.default
        '';
        description = "Test the implementation.";
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
          # Docs
          astro-language-server
          markdownlint-cli
          bun
        ]
        ++ builtins.attrValues scriptPackages;
    };
    packages = pkgs.lib.genAttrs (builtins.attrNames scripts) (name: scriptPackages.${name});
  };
}
