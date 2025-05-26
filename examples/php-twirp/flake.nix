{
  description = "Bufrnix PHP Twirp example";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "github:conneroisu/bufrnix/php";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    bufrnix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          # Allow for unfree packages like PHP extensions
          config.allowUnfree = true;
        };
        # Create a bufrnix package for this project
        bufrnixPackage = bufrnix.lib.mkBufrnixPackage {
          inherit (nixpkgs.legacyPackages.${system}) lib;
          inherit pkgs;
          config = {
            root = ./.;
            debug.enable = true;
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
            };
            languages.php = {
              enable = true;
              outputPath = "proto/gen/php";
              namespace = "Example\\Twirp";
              twirp = {
                enable = true;
              };
            };
          };
        };
      in {
        packages = {
          default = bufrnixPackage;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.php
            pkgs.phpactor
            bufrnixPackage
          ];
        };
      }
    );
}
