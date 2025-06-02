{
  description = "JavaScript with protovalidate-es example";

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
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;

          config = {
            root = ./.;
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
              files = ["./proto/example/v1/user.proto"];
            };
            languages.js = {
              enable = true;
              outputPath = "./proto/gen/js";
              es.enable = true;
              protovalidate = {
                enable = true;
                target = "ts";
                generateValidationHelpers = true;
              };
            };
          };
        };
      };

      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.nodejs
          pkgs.nodePackages.typescript
        ];

        shellHook = ''
          echo "JavaScript/TypeScript with protovalidate-es Development Shell"
          echo "============================================================"
          echo ""
          echo "This example demonstrates using protovalidate-es for runtime"
          echo "validation of Protocol Buffer messages in TypeScript."
          echo ""
          echo "Available commands:"
          echo "  nix build        - Generate TypeScript code from proto files"
          echo "  npm install      - Install dependencies"
          echo "  npm run build    - Build the TypeScript code"
          echo "  npm run validate - Run validation examples"
          echo ""
        '';
      };
    });
}
