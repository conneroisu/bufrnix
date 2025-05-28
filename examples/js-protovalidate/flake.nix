{
  description = "JavaScript with protovalidate-es example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix = {
      url = "github:conneroisu/bufrnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    bufrnix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      bufrnixLib = bufrnix.lib.${system};
    in {
      devShells.default = bufrnixLib.mkShell {
        languages.js = {
          enable = true;
          es.enable = true;
          protovalidate = {
            enable = true;
            target = "ts";
            generateValidationHelpers = true;
          };
        };

        shellHook = ''
          echo "JavaScript/TypeScript with protovalidate-es Development Shell"
          echo "============================================================"
          echo ""
          echo "This example demonstrates using protovalidate-es for runtime"
          echo "validation of Protocol Buffer messages in TypeScript."
          echo ""
          echo "Available commands:"
          echo "  bufrnix_generate - Generate TypeScript code from proto files"
          echo "  npm install      - Install dependencies"
          echo "  npm run build    - Build the TypeScript code"
          echo "  npm run validate - Run validation examples"
          echo ""
        '';
      };
    });
}
