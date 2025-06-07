{
  description = "Multi-language multi-project enterprise-scale protobuf example";

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

      buildWithSpecificGo = pkg:
        pkg.override {
          buildGoModule = pkgs.buildGo124Module;
        };
    in {
      # Main development shell with all tools
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nixd
          alejandra
          # Multi-language development tools
          go
          protoc-gen-go
          protoc-gen-go-grpc

          go_1_24 # Go Tools
          air
          templ
          golangci-lint
          (buildWithSpecificGo revive)
          (buildWithSpecificGo gopls)
          (buildWithSpecificGo templ)
          (buildWithSpecificGo golines)
          (buildWithSpecificGo golangci-lint-langserver)
          (buildWithSpecificGo gomarkdoc)
          (buildWithSpecificGo gotests)
          (buildWithSpecificGo gotools)
          (buildWithSpecificGo reftools)
          pprof
          graphviz

          python3
          python3Packages.grpcio
          python3Packages.grpcio-tools
          python3Packages.protobuf
          python3Packages.mypy
          python3Packages.black
          python3Packages.pylint

          nodejs
          nodePackages.typescript
          nodePackages.eslint
          nodePackages.prettier

          # Protocol buffers and gRPC tools
          buf
          protobuf
          grpc

          # Documentation and OpenAPI tools
          swagger-codegen3

          # Development utilities
          jq
          curl
          git
        ];

        shellHook = ''
          echo "Multi-Language Multi-Project Protobuf Example"
          echo "============================================="
          echo ""
          echo "This example demonstrates enterprise-scale protobuf usage with:"
          echo "  - Multiple microservices (API, ASR, TTS, LLM, Image processing, etc.)"
          echo "  - Shared library definitions (Language codes, Media types)"
          echo "  - Multi-language code generation (Go, Python, JavaScript, Swift, etc.)"
          echo "  - OpenAPI/Swagger documentation generation"
          echo "  - gRPC gateway integration"
          echo ""
          echo "Available commands:"
          echo "  nix build                    - Generate all protobuf code"
          echo "  nix develop .#go            - Go development environment"
          echo "  nix develop .#python        - Python development environment"
          echo "  nix develop .#javascript    - JavaScript development environment"
          echo "  nix develop .#docs          - Documentation environment"
          echo ""
          echo "Example implementations:"
          echo "  examples/go/main.go         - Go client example"
          echo "  examples/python/main.py     - Python client example"
          echo "  examples/javascript/index.js - JavaScript client example"
          echo ""
          echo "Generated code directories:"
          echo "  proto/gen/go/               - Go packages"
          echo "  proto/gen/python/           - Python modules"
          echo "  proto/gen/swift/            - Swift packages"
          echo "  proto/gen/dart/             - Dart packages"
          echo "  proto/gen/cpp/              - C++ libraries"
          echo "  proto/gen/doc/              - HTML documentation"
          echo "  proto/gen/openapi/          - OpenAPI specifications"
          echo ""
        '';
      };

      # Language-specific development shells
      devShells = {
        go = pkgs.mkShell {
          packages = with pkgs; [
            go
            protoc-gen-go
            protoc-gen-go-grpc
            buf
            golangci-lint
            delve
          ];
          shellHook = ''
            echo "Go Development Environment for Multi-Project"
            echo "Generated Go code: proto/gen/go/"
            echo "Example: examples/go/main.go"
            cd examples/go
          '';
        };

        python = pkgs.mkShell {
          packages = with pkgs; [
            python3
            python3Packages.grpcio
            python3Packages.grpcio-tools
            python3Packages.protobuf
            python3Packages.mypy
            python3Packages.black
            python3Packages.pylint
            python3Packages.pytest
            buf
          ];
          shellHook = ''
            echo "Python Development Environment for Multi-Project"
            echo "Generated Python code: proto/gen/python/"
            echo "Example: examples/python/main.py"
            cd examples/python
          '';
        };

        javascript = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            nodePackages.typescript
            nodePackages.eslint
            nodePackages.prettier
            buf
          ];
          shellHook = ''
            echo "JavaScript/TypeScript Development Environment for Multi-Project"
            echo "Generated JS code: proto/gen/js/"
            echo "Example: examples/javascript/index.js"
            cd examples/javascript
          '';
        };

        docs = pkgs.mkShell {
          packages = with pkgs; [
            buf
            protobuf
            swagger-codegen3
            python3Packages.mkdocs
            python3Packages.mkdocs-material
          ];
          shellHook = ''
            echo "Documentation Development Environment"
            echo "Generated docs: proto/gen/doc/"
            echo "OpenAPI specs: proto/gen/openapi/"
          '';
        };
      };

      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;

          config = {
            root = ./.;
            protoc = {
              sourceDirectories = ["./proto/src"];
              includeDirectories = ["./proto/src" "./proto/lib"];
              files = [
                "./proto/src/edi/v1/edit.proto"
                "./proto/src/asr/v1/asr.proto"
                "./proto/src/emb/v1/emb.proto"
                "./proto/src/img/v1/img.proto"
                "./proto/src/llm/v1/llm.proto"
                "./proto/src/seg/v1/seg.proto"
                "./proto/src/tts/v1/tts.proto"
                "./proto/src/vari/v1/vari.proto"
                "./proto/src/vid/v1/vid.proto"
                "./proto/src/api/v1/api.proto"
              ];
            };

            languages = {
              # Go with comprehensive plugin support
              go = {
                enable = true;
                outputPath = "proto/gen/go";

                # Core protobuf and gRPC
                grpc.enable = true;
                json.enable = true;

                # Gateway and OpenAPI generation
                gateway = {
                  enable = true;
                  outputPath = "proto/gen/go";
                };

                openapiv2 = {
                  enable = true;
                  outputPath = "proto/gen/openapi";
                };

                # Performance optimizations
                vtprotobuf = {
                  enable = true;
                  options = [
                    "paths=source_relative"
                    "features=marshal+unmarshal+size+pool"
                  ];
                };
              };

              # Python with full typing support
              python = {
                enable = true;
                outputPath = "proto/gen/python";
                grpc.enable = true;
                mypy.enable = true;
              };

              # JavaScript with modern ES modules
              js = {
                enable = true;
                outputPath = "proto/gen/js";
                packageName = "pegwings-proto";
                es.enable = true;
              };

              # Swift for iOS/macOS applications
              swift = {
                enable = true;
                outputPath = "proto/gen/swift";
                grpc.enable = true;
              };

              # Dart for Flutter applications
              dart = {
                enable = true;
                outputPath = "proto/gen/dart";
                grpc.enable = true;
              };

              # C++ for high-performance applications
              cpp = {
                enable = true;
                outputPath = "proto/gen/cpp";
                grpc.enable = true;
              };

              # Documentation generation
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
