{
  description = "bufrnix documentation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bun2nix.url = "github:baileyluTCD/bun2nix";
    bun2nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    nixpkgs,
    bun2nix,
    treefmt-nix,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Evaluate the treefmt modules from ./treefmt.nix
    treefmtEval = forAllSystems (
      system:
        treefmt-nix.lib.evalModule
        nixpkgs.legacyPackages.${system}
        ./treefmt.nix
    );
  in {
    formatter = forAllSystems (
      system:
        treefmtEval.${system}.config.build.wrapper
    );

    checks = forAllSystems (system: {
      formatting = treefmtEval.${system}.config.build.check ./.;
    });

    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          bun
          bun2nix.packages.${system}.default
          # Include the treefmt wrapper
          treefmtEval.${system}.config.build.wrapper
        ];
      };
    });

    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      bufrnix-docs = pkgs.callPackage ./default.nix {
        inherit (bun2nix.lib.${system}) mkBunDerivation;
      };
    });
  };
}
