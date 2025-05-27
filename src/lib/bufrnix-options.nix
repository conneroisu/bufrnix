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
      };

      # Additional language options will be defined here
      # For example, python, rust, typescript, etc.

      # PHP language options
      php = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable PHP code generation";
        };

        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.php.withExtensions ({ enabled, all }: enabled ++ [ all.grpc all.protobuf ])";
          description = "PHP package with required extensions";
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
          default = "Generated";
          description = "Base namespace for generated PHP code";
        };

        metadataNamespace = mkOption {
          type = types.str;
          default = "GPBMetadata";
          description = "Namespace for protobuf metadata";
        };

        classPrefix = mkOption {
          type = types.str;
          default = "";
          description = "Prefix for generated PHP classes";
        };

        composer = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable Composer dependency management";
          };

          autoInstall = mkOption {
            type = types.bool;
            default = false;
            description = "Automatically install Composer dependencies";
          };
        };

        # gRPC support
        grpc = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC client generation";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.grpc";
            description = "The gRPC package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to grpc PHP plugin";
          };

          clientOnly = mkOption {
            type = types.bool;
            default = false;
            description = "Generate only client code (no server stubs)";
          };

          serviceNamespace = mkOption {
            type = types.str;
            default = "Services";
            description = "Namespace suffix for service classes";
          };
        };

        # RoadRunner support
        roadrunner = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable RoadRunner gRPC server generation";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.roadrunner";
            description = "The RoadRunner package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to RoadRunner plugin";
          };

          workers = mkOption {
            type = types.int;
            default = 4;
            description = "Number of worker processes";
          };

          maxJobs = mkOption {
            type = types.int;
            default = 64;
            description = "Maximum jobs per worker before restart";
          };

          maxMemory = mkOption {
            type = types.int;
            default = 128;
            description = "Maximum memory per worker (MB)";
          };

          tlsEnabled = mkOption {
            type = types.bool;
            default = false;
            description = "Enable TLS for gRPC server";
          };
        };

        # Framework integrations
        frameworks = {
          laravel = {
            enable = mkOption {
              type = types.bool;
              default = false;
              description = "Enable Laravel framework integration";
            };

            serviceProvider = mkOption {
              type = types.bool;
              default = true;
              description = "Generate Laravel service provider";
            };

            artisanCommands = mkOption {
              type = types.bool;
              default = true;
              description = "Generate Artisan commands for protobuf";
            };
          };

          symfony = {
            enable = mkOption {
              type = types.bool;
              default = false;
              description = "Enable Symfony framework integration";
            };

            bundle = mkOption {
              type = types.bool;
              default = true;
              description = "Generate Symfony bundle";
            };

            messengerIntegration = mkOption {
              type = types.bool;
              default = true;
              description = "Integrate with Symfony Messenger";
            };
          };
        };

        # Async PHP support
        async = {
          reactphp = {
            enable = mkOption {
              type = types.bool;
              default = false;
              description = "Enable ReactPHP integration";
            };

            version = mkOption {
              type = types.str;
              default = "^1.0";
              description = "ReactPHP version constraint";
            };
          };

          swoole = {
            enable = mkOption {
              type = types.bool;
              default = false;
              description = "Enable Swoole/OpenSwoole integration";
            };

            coroutines = mkOption {
              type = types.bool;
              default = true;
              description = "Enable coroutine support";
            };
          };

          fibers = {
            enable = mkOption {
              type = types.bool;
              default = false;
              description = "Enable PHP 8.1+ Fiber support";
            };
          };
        };

        # Legacy Twirp support (deprecated)
        twirp = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Twirp RPC framework code generation for PHP (deprecated - use gRPC instead)";
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
