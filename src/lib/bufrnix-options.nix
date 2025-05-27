{lib, ...}:
with lib; {
  options = {
    # Basic configuration
    root = mkOption {
      type = types.str;
      default = "./proto";
      description = "Root directory for proto files";
    };

    # Debug options
    debug = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable debug mode";
      };

      verbosity = mkOption {
        type = types.int;
        default = 1;
        description = "Debug verbosity level (1-3)";
      };

      logFile = mkOption {
        type = types.str;
        default = "";
        description = "Path to debug log file. If empty, logs to stdout";
      };
    };

    # protoc options
    protoc = {
      sourceDirectories = mkOption {
        type = types.listOf types.str;
        default = ["./proto"];
        description = "Directories containing proto files to compile";
      };

      includeDirectories = mkOption {
        type = types.listOf types.str;
        default = ["./proto"];
        description = "Directories to include in the include path";
      };

      files = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Specific proto files to compile (leave empty to compile all)";
      };
    };

    # Language options
    languages = {
      # Go language options
      go = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Go code generation";
        };

        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.protoc-gen-go";
          description = "The protoc-gen-go package to use";
        };

        outputPath = mkOption {
          type = types.str;
          default = "gen/go";
          description = "Output directory for generated Go code";
        };

        options = mkOption {
          type = types.listOf types.str;
          default = ["paths=source_relative"];
          description = "Options to pass to protoc-gen-go";
        };

        packagePrefix = mkOption {
          type = types.str;
          default = "";
          description = "Go package prefix for generated code";
        };

        plugins = mkOption {
          type = types.listOf (types.either types.str (types.attrsOf types.anything));
          default = [];
          example = literalExpression ''
            [
              "buf.build/protocolbuffers/go"
              {
                plugin = "buf.build/community/planetscale-vtprotobuf";
                opt = ["features=marshal+unmarshal+size+pool"];
              }
            ]
          '';
          description = ''
            List of Go plugins to enable using Buf registry names.
            Can be either a string (using default options) or an attribute set
            with 'plugin' and 'opt' fields for custom options.
          '';
        };

        grpc = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC code generation for Go";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-go-grpc";
            description = "The protoc-gen-go-grpc package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = ["paths=source_relative"];
            description = "Options to pass to protoc-gen-go-grpc";
          };
        };

        # Support for other Go-related plugins
        gateway = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC-Gateway code generation for Go";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.grpc-gateway";
            description = "The grpc-gateway package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = ["paths=source_relative"];
            description = "Options to pass to protoc-gen-grpc-gateway";
          };
        };

        validate = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable protoc-gen-validate for Go";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-validate";
            description = "The protoc-gen-validate package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = ["lang=go"];
            description = "Options to pass to protoc-gen-validate";
          };
        };

        connect = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Connect code generation for Go";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-connect-go";
            description = "The protoc-gen-connect-go package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = ["paths=source_relative"];
            description = "Options to pass to protoc-gen-connect-go";
          };
        };

        protovalidate = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable protovalidate support for Go (modern validation using CEL expressions)";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protovalidate-go";
            description = "The protovalidate-go package to use";
          };
        };

        openapiv2 = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable OpenAPI v2 documentation generation";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-openapiv2";
            description = "The protoc-gen-openapiv2 package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = ["logtostderr=true"];
            description = "Options to pass to protoc-gen-openapiv2";
          };
        };

        vtprotobuf = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable vtprotobuf for high-performance serialization (3.8x faster)";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-go-vtproto";
            description = "The protoc-gen-go-vtproto package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = ["paths=source_relative" "features=marshal+unmarshal+size"];
            description = "Options to pass to protoc-gen-go-vtproto";
          };
        };

        json = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable JSON integration with encoding/json";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-go-json";
            description = "The protoc-gen-go-json package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = ["paths=source_relative" "orig_name=true"];
            description = "Options to pass to protoc-gen-go-json";
          };
        };

        federation = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC Federation for automatic BFF server generation (experimental)";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-grpc-federation";
            description = "The protoc-gen-grpc-federation package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = ["paths=source_relative"];
            description = "Options to pass to protoc-gen-grpc-federation";
          };
        };
      };

      # Additional language options will be defined here
      # For example, python, rust, typescript, etc.

      # C++ language options
      cpp = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable C++ code generation";
        };

        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.protobuf";
          description = "The protobuf package to use for C++ generation";
        };

        protobufVersion = mkOption {
          type = types.enum ["3.21" "3.25" "3.27" "4.25" "5.29" "latest"];
          default = "latest";
          description = "Protobuf version to use";
        };

        outputPath = mkOption {
          type = types.str;
          default = "gen/cpp";
          description = "Output directory for generated C++ code";
        };

        options = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Options to pass to protoc C++ plugins";
        };

        standard = mkOption {
          type = types.enum ["c++17" "c++20" "c++23"];
          default = "c++17";
          description = "C++ standard to use";
        };

        optimizeFor = mkOption {
          type = types.enum ["SPEED" "CODE_SIZE" "LITE_RUNTIME"];
          default = "SPEED";
          description = "Optimization mode for generated code";
        };

        runtime = mkOption {
          type = types.enum ["full" "lite"];
          default = "full";
          description = "Protobuf runtime type (full or lite)";
        };

        cmakeIntegration = mkOption {
          type = types.bool;
          default = true;
          description = "Generate CMake integration files";
        };

        pkgConfigIntegration = mkOption {
          type = types.bool;
          default = true;
          description = "Generate pkg-config files";
        };

        includePaths = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Additional include paths for C++ compilation";
        };

        arenaAllocation = mkOption {
          type = types.bool;
          default = false;
          description = "Enable arena allocation for better performance";
        };

        grpc = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC code generation for C++";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.grpc";
            description = "The gRPC package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-grpc-cpp";
          };

          generateMockCode = mkOption {
            type = types.bool;
            default = false;
            description = "Generate mock code for testing";
          };
        };

        nanopb = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable nanopb for embedded C/C++";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.nanopb";
            description = "The nanopb package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = ["max_size=1024" "max_count=16"];
            description = "Options to pass to protoc-gen-nanopb";
          };
        };

        protobuf-c = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable pure C code generation";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protobuf-c";
            description = "The protobuf-c package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-c";
          };
        };
      };

      # PHP language options
      php = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable PHP code generation";
        };

        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.protobuf";
          description = "The protobuf package to use for PHP generation";
        };

        outputPath = mkOption {
          type = types.str;
          default = "gen/php";
          description = "Output directory for generated PHP code";
        };

        options = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Options to pass to protoc PHP plugins";
        };

        namespace = mkOption {
          type = types.str;
          default = "";
          description = "PHP namespace for generated code";
        };

        twirp = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Twirp RPC framework code generation for PHP";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-twirp_php";
            description = "The protoc-gen-twirp_php package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-twirp_php";
          };
        };
      };

      # JavaScript language options
      js = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable JavaScript/TypeScript code generation";
        };

        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.protoc-gen-js";
          description = "The protoc-gen-js package to use";
        };

        outputPath = mkOption {
          type = types.str;
          default = "gen/js";
          description = "Output directory for generated JavaScript code";
        };

        options = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Options to pass to protoc JS plugins";
        };

        packageName = mkOption {
          type = types.str;
          default = "";
          description = "JavaScript package name for generated code";
        };

        # ECMAScript modules support
        es = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable ECMAScript modules generation (modern JavaScript)";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-es";
            description = "The protoc-gen-es package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-es";
          };
        };

        # Connect-ES for RPC
        connect = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Connect-ES code generation for JavaScript (modern RPC)";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-connect-es";
            description = "The protoc-gen-connect-es package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-connect-es";
          };
        };

        # gRPC-Web for browser-compatible RPC
        grpcWeb = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC-Web code generation for JavaScript";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.grpc-web";
            description = "The protoc-gen-grpc-web package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-grpc-web";
          };
        };

        # Twirp RPC support
        twirp = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Twirp RPC framework code generation for JavaScript";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-twirp_js";
            description = "The protoc-gen-twirp_js package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-twirp_js";
          };
        };
      };

      # Dart language options
      dart = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Dart code generation";
        };

        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.protoc-gen-dart";
          description = "The protoc-gen-dart package to use";
        };

        outputPath = mkOption {
          type = types.str;
          default = "lib/proto";
          description = "Output directory for generated Dart code";
        };

        options = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Options to pass to protoc-gen-dart";
        };

        packageName = mkOption {
          type = types.str;
          default = "";
          description = "Dart package name for generated code";
        };

        grpc = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC code generation for Dart";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-dart";
            description = "The protoc-gen-dart package to use (same as parent for Dart)";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-dart for gRPC";
          };
        };
      };

      # Documentation language options
      doc = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable documentation generation with protoc-gen-doc";
        };

        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.protoc-gen-doc";
          description = "The protoc-gen-doc package to use";
        };

        outputPath = mkOption {
          type = types.str;
          default = "gen/doc";
          description = "Output directory for generated documentation";
        };

        options = mkOption {
          type = types.listOf types.str;
          default = ["html,index.html"];
          description = "Options to pass to protoc-gen-doc (format,output_file)";
        };

        format = mkOption {
          type = types.enum ["html" "markdown" "json" "docbook"];
          default = "html";
          description = "Documentation output format";
        };

        outputFile = mkOption {
          type = types.str;
          default = "index.html";
          description = "Output filename for the documentation";
        };
      };

      # SVG diagram generation options
      svg = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable SVG diagram generation with protoc-gen-d2";
        };

        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.protoc-gen-d2";
          description = "The protoc-gen-d2 package to use";
        };

        outputPath = mkOption {
          type = types.str;
          default = "gen/svg";
          description = "Output directory for generated SVG diagrams";
        };

        options = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Options to pass to protoc-gen-d2";
        };
      };

      # Python language options
      python = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Python code generation";
        };

        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.protobuf";
          description = "The protobuf package to use for Python generation";
        };

        outputPath = mkOption {
          type = types.str;
          default = "gen/python";
          description = "Output directory for generated Python code";
        };

        options = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Options to pass to protoc Python plugins";
        };

        grpc = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC code generation for Python";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.python3Packages.grpcio-tools";
            description = "The grpcio-tools package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to grpc_python plugin";
          };
        };

        pyi = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Python type stub (.pyi) generation";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protobuf";
            description = "The protobuf package to use for pyi generation";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to pyi plugin";
          };
        };

        betterproto = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable betterproto (modern Python dataclasses) generation";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.python3Packages.betterproto";
            description = "The betterproto package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to betterproto plugin";
          };
        };

        mypy = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable mypy stub generation";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.python3Packages.mypy-protobuf";
            description = "The mypy-protobuf package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to mypy plugin";
          };
        };
      };

      # Swift language options
      swift = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Swift code generation";
        };

        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.protoc-gen-swift";
          description = "The protoc-gen-swift package to use";
        };

        outputPath = mkOption {
          type = types.str;
          default = "gen/swift";
          description = "Output directory for generated Swift code";
        };

        options = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Options to pass to protoc-gen-swift";
        };

        packageName = mkOption {
          type = types.str;
          default = "";
          description = "Swift package name for generated code";
        };
      };

      # C language options
      c = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable C code generation";
        };

        outputPath = mkOption {
          type = types.str;
          default = "gen/c";
          description = "Output directory for generated C code";
        };

        # protobuf-c support
        protobuf-c = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable protobuf-c code generation (standard C implementation)";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protobuf-c";
            description = "The protobuf-c package to use";
          };

          outputPath = mkOption {
            type = types.str;
            default = "gen/c/protobuf-c";
            description = "Output directory for generated protobuf-c code";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-c";
          };
        };

        # nanopb support
        nanopb = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable nanopb code generation (embedded/lightweight C implementation)";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.nanopb";
            description = "The nanopb package to use";
          };

          outputPath = mkOption {
            type = types.str;
            default = "gen/c/nanopb";
            description = "Output directory for generated nanopb code";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-nanopb";
          };

          # Nanopb-specific configuration
          maxSize = mkOption {
            type = types.int;
            default = 1024;
            description = "Maximum size for dynamic allocation in nanopb";
          };

          fixedLength = mkOption {
            type = types.bool;
            default = false;
            description = "Use fixed length arrays in nanopb";
          };

          noUnions = mkOption {
            type = types.bool;
            default = false;
            description = "Disable union support in nanopb";
          };

          msgidType = mkOption {
            type = types.str;
            default = "";
            description = "Message ID type for nanopb";
          };
        };

        # upb support (future - not yet in nixpkgs)
        upb = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable upb code generation (Google's C implementation) - not yet available";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-upb";
            description = "The protoc-gen-upb package to use";
          };

          outputPath = mkOption {
            type = types.str;
            default = "gen/c/upb";
            description = "Output directory for generated upb code";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-upb";
          };
        };
      };
    };
  };
}
