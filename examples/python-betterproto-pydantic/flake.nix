{
  description = "Python with betterproto and Pydantic example";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.url = "path:../..";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    bufrnix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      bufrnixConfig = bufrnix.lib.mkBufrnixPackage {
        inherit pkgs;

        config = {
          root = "./proto";

          # Python with betterproto and Pydantic for validated dataclasses
          languages.python = {
            enable = true;
            outputPath = "proto/gen/python";

            # Use betterproto with Pydantic validation
            betterproto = {
              enable = true;
              pydantic = true;
            };
          };
        };
      };
    in {
      packages.default = bufrnixConfig;
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python3
          python3Packages.betterproto
          python3Packages.pydantic # Required for Pydantic dataclasses
          python3Packages.grpclib # betterproto uses grpclib instead of grpcio
          python3Packages.black # Required for betterproto compiler
          python3Packages.isort # Required for betterproto compiler
          protobuf
        ];

        shellHook = ''
          echo "Python Betterproto with Pydantic Example"
          echo "========================================"
          echo "Commands:"
          echo "  nix run .#default - Generate betterproto with Pydantic code"
          echo "  python test_pydantic.py - Run validation test"
          echo ""
          echo "Note: Betterproto with Pydantic generates validated dataclasses"
          echo "      with async support, cleaner API, and data validation"
          echo ""

          # Add the bufrnix package to PATH
          export PATH="${bufrnixConfig}/bin:$PATH"
        '';
      };
    });
}
