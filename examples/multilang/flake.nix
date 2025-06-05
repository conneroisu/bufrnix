{
  description = "Multi-language protobuf example using bufrnix";

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
    in {
      # Development shell with tools for all languages
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # Go
          go
          protoc-gen-go
          protoc-gen-go-grpc

          # Python
          python3
          python3Packages.grpcio
          python3Packages.grpcio-tools
          python3Packages.protobuf
          python3Packages.mypy

          # JavaScript/TypeScript
          nodejs
          nodePackages.typescript

          # Java
          jdk17
          gradle

          # C++
          gcc
          cmake
          protobuf
          grpc

          # Swift
          swift

          # Development tools
          buf
          protobuf
        ];

        shellHook = ''
          echo "Multi-Language Bufrnix Example"
          echo "============================="
          echo ""
          echo "This example demonstrates protobuf code generation for multiple languages:"
          echo "  - Go (with gRPC)"
          echo "  - Python (with gRPC and mypy stubs)"
          echo "  - JavaScript/TypeScript (with ES modules)"
          echo "  - Java (with gRPC)"
          echo "  - C++ (with gRPC)"
          echo "  - Swift"
          echo ""
          echo "Available commands:"
          echo "  nix build              - Generate code for all languages"
          echo "  nix develop .#go       - Enter Go development shell"
          echo "  nix develop .#python   - Enter Python development shell"
          echo "  nix develop .#js       - Enter JavaScript development shell"
          echo "  nix develop .#java     - Enter Java development shell"
          echo "  nix develop .#cpp      - Enter C++ development shell"
          echo "  nix develop .#swift    - Enter Swift development shell"
          echo ""
          echo "Generated code will be available in: proto/gen/<language>/"
          echo ""
        '';
      };

      # Language-specific development shells
      devShells = {
        go = pkgs.mkShell {
          packages = with pkgs; [go protoc-gen-go protoc-gen-go-grpc buf];
          shellHook = ''
            echo "Go Development Environment"
            echo "Go code: proto/gen/go/"
          '';
        };

        python = pkgs.mkShell {
          packages = with pkgs; [
            python3
            python3Packages.grpcio
            python3Packages.grpcio-tools
            python3Packages.protobuf
            python3Packages.mypy
            buf
          ];
          shellHook = ''
            echo "Python Development Environment"
            echo "Python code: proto/gen/python/"
          '';
        };

        js = pkgs.mkShell {
          packages = with pkgs; [nodejs nodePackages.typescript buf];
          shellHook = ''
            echo "JavaScript/TypeScript Development Environment"
            echo "JS code: proto/gen/js/"
          '';
        };

        java = pkgs.mkShell {
          packages = with pkgs; [jdk17 gradle buf];
          shellHook = ''
            echo "Java Development Environment"
            echo "Java code: proto/gen/java/"
          '';
        };

        cpp = pkgs.mkShell {
          packages = with pkgs; [gcc cmake protobuf grpc buf];
          shellHook = ''
            echo "C++ Development Environment"
            echo "C++ code: proto/gen/cpp/"
          '';
        };

        swift = pkgs.mkShell {
          packages = with pkgs; [swift buf];
          shellHook = ''
            echo "Swift Development Environment"
            echo "Swift code: proto/gen/swift/"
          '';
        };
      };

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

            languages = {
              # Go with gRPC support
              go = {
                enable = true;
                outputPath = "proto/gen/go";
                grpc.enable = true;
                json.enable = true;
              };

              # Python with gRPC and mypy stubs
              python = {
                enable = true;
                outputPath = "proto/gen/python";
                grpc.enable = true;
                mypy.enable = true;
              };

              # JavaScript with ES modules
              js = {
                enable = true;
                outputPath = "proto/gen/js";
                packageName = "multilang-example";
                es.enable = true;
              };

              # Java with gRPC
              java = {
                enable = true;
                outputPath = "proto/gen/java";
                grpc.enable = true;
              };

              # C++ with gRPC
              cpp = {
                enable = true;
                outputPath = "proto/gen/cpp";
                grpc.enable = true;
              };

              # Documentation
              doc = {
                enable = true;
                outputPath = "proto/gen/doc";
              };
            };
          };
        };
      };
    });
}