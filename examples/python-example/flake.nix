{
  description = "Python example using bufrnix";

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

      # Create bufrnix configuration for Python
      bufrnixConfig = bufrnix.lib.mkBufrnix {
        inherit pkgs;
        config = {
          # Basic configuration
          root = "./proto";
          debug.enable = true;

          # Python language configuration
          languages.python = {
            enable = true;
            outputPath = "proto/gen/python";
            options = []; # No special options for basic generation

            # Enable gRPC support
            grpc = {
              enable = true;
              options = [];
            };

            # Enable type stubs for better IDE support
            pyi = {
              enable = true;
              options = [];
            };

            # Enable mypy stubs for type checking
            mypy = {
              enable = true;
              options = [];
            };

            # Optionally enable betterproto for modern Python
            betterproto = {
              enable = false; # Disabled by default, enable if you want dataclasses
              options = [];
            };
          };
        };
      };
    in {
      # Development shell with Python and generated code
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Python environment
          python3
          python3Packages.grpcio
          python3Packages.grpcio-tools
          python3Packages.protobuf
          python3Packages.mypy
          python3Packages.black
          python3Packages.pytest

          # Development tools
          buf
          protobuf
        ];

        shellHook = ''
          echo "Python Bufrnix Example"
          echo "====================="
          echo ""
          echo "Available commands:"
          echo "  bufrnix_init    - Initialize the project structure"
          echo "  bufrnix         - Generate Python protobuf code"
          echo "  bufrnix_lint    - Lint proto files with buf"
          echo "  python main.py  - Run the example Python client"
          echo "  pytest          - Run tests"
          echo ""
          echo "Python code will be generated in: proto/gen/python/"
          echo ""

          # Add the bufrnix commands to the environment
          ${bufrnixConfig.shellHook}
        '';
      };

      # Package the generated Python code
      packages.python-proto = pkgs.python3Packages.buildPythonPackage {
        pname = "example-proto";
        version = "0.1.0";
        src = ./.;

        propagatedBuildInputs = with pkgs.python3Packages; [
          grpcio
          protobuf
        ];

        preBuild = ''
          # Generate the protobuf code
          ${bufrnixConfig.generate}
        '';

        # Include the generated files
        pythonImportsCheck = ["example"];
      };
    });
}
