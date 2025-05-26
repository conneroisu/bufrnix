{
  description = "Basic Python protobuf example";

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

      bufrnixConfig = bufrnix.lib.mkBufrnix {
        inherit pkgs;
        config = {
          root = "./proto";

          # Basic Python configuration - only protobuf messages
          languages.python = {
            enable = true;
            outputPath = "proto/gen/python";
          };
        };
      };
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
          echo "  bufrnix_init - Initialize project"
          echo "  bufrnix - Generate Python code"
          echo "  python test.py - Run test script"
          echo ""
          ${bufrnixConfig.shellHook}
        '';
      };
    });
}
