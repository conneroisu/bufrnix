{
  description = "Bufrnix PHP Twirp example";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "path:../..";
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
