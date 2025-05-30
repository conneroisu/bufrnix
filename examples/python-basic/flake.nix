{
  description = "Basic Python protobuf example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "path:../..";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    bufrnix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python3
          python3Packages.protobuf
          protobuf
        ];

        shellHook = ''
          echo "Basic Python Protobuf Example"
          echo "============================"
          echo "Commands:"
          echo "  nix build - Generate Python code"
          echo "  python test.py - Run test script"
          echo ""
        '';
      };
      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;

          config = {
            root = ./.;
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
            };

            # Basic Python configuration - only protobuf messages
            languages.python = {
              enable = true;
              outputPath = "proto/gen/python";
            };
          };
        };
      };
    });
}
