{
  description = "Python with type stubs example";

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

          # Python with type stubs for IDE and mypy
          languages.python = {
            enable = true;
            outputPath = "proto/gen/python";

            grpc = {
              enable = true;
            };

            pyi = {
              enable = true;
            };

            mypy = {
              enable = true;
            };
          };
        };
      };
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python3
          python3Packages.protobuf
          python3Packages.grpcio
          python3Packages.grpcio-tools
          python3Packages.mypy
          python3Packages.mypy-protobuf
          protobuf
        ];

        shellHook = ''
          echo "Python Type Stubs Example"
          echo "========================"
          echo "Commands:"
          echo "  bufrnix_init - Initialize project"
          echo "  bufrnix - Generate Python + type stubs"
          echo "  python test_types.py - Run type test"
          echo "  mypy test_types.py - Type check the code"
          echo ""
          ${bufrnixConfig.shellHook}
        '';
      };
    });
}
