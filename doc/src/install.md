# Install

## Nix/NixOS

Flake:

```nix
{
    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
    inputs.gohard.url = "github:conneroisu/gohard";
    inputs.gohard.inputs.nixpkgs.follows = "nixpkgs";


    outputs = { self, gohard, nixpkgs, flake-utils, ... }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = nixpkgs.legacyPackages.${system};
                gohard = pkgs.callPackage gohard.default { };
            in
            {
                defaultPackage = gohard;
                packages.default = gohard;
            }
        );
}
```
