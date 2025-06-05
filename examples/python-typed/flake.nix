{
  description = "Python with type stubs example";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix = {
      url = "path:../..";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    bufrnix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      bufrnixPackage = bufrnix.lib.mkBufrnixPackage {
        inherit pkgs;

        config = {
          root = ./.;

          protoc = {
            sourceDirectories = ["./proto"];
            includeDirectories = ["./proto"];
          };

          # Python with type stubs for IDE and mypy
          languages.python = {
            enable = true;
            outputPath = "./proto/gen/python";

            grpc = {
              enable = true;
            };

            # Use mypy for type stubs (not pyi)
            mypy = {
              enable = true;
            };
          };
        };
      };
    in {
      packages.default = bufrnixPackage;
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python3
          python3Packages.protobuf
          python3Packages.grpcio
          python3Packages.grpcio-tools
          python3Packages.mypy
          python3Packages.mypy-protobuf
          protobuf
          bufrnixPackage
        ];

        shellHook = ''
          echo "Python Type Stubs Example"
          echo "========================"
          echo "Commands:"
          echo "  bufrnix - Generate Python + type stubs"
          echo "  python test_types.py - Run type test"
          echo "  mypy test_types.py - Type check the code"
          echo ""
          echo "Run 'bufrnix' to generate code from proto files."
        '';
      };
    });
}
