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
          type = types.either types.str (types.listOf types.str);
          default = "gen/go";
          description = "Output directory(ies) for generated Go code";
          example = literalExpression ''
            [
              "gen/go"
              "pkg/proto"
              "internal/shared/proto"
            ]
          '';
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

        structTransformer = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable struct-transformer for generating transformation functions between protobuf and business logic structs";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-struct-transformer";
            description = "The protoc-gen-struct-transformer package to use";
          };

          goRepoPackage = mkOption {
            type = types.str;
            default = "models";
            description = "Go package name for business logic models";
          };

          goProtobufPackage = mkOption {
            type = types.str;
            default = "proto";
            description = "Go package name for protobuf generated code";
          };

          goModelsFilePath = mkOption {
            type = types.str;
            default = "models/models.go";
            description = "Path to the Go file containing business logic struct definitions";
          };

          outputPackage = mkOption {
            type = types.str;
            default = "transform";
            description = "Package name for generated transformation functions";
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
          type = types.either types.str (types.listOf types.str);
          default = "gen/cpp";
          description = "Output directory(ies) for generated C++ code";
          example = literalExpression ''
            [
              "gen/cpp"
              "src/proto"
            ]
          '';
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
          defaultText = literalExpression "pkgs.php.withExtensions ({ enabled, all }: enabled ++ [ all.grpc all.protobuf ])";
          description = "PHP package with required extensions";
        };

        outputPath = mkOption {
          type = types.either types.str (types.listOf types.str);
          default = "gen/php";
          description = "Output directory(ies) for generated PHP code";
          example = literalExpression ''
            [
              "gen/php"
              "src/proto"
              "app/Proto"
            ]
          '';
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
          type = types.either types.str (types.listOf types.str);
          default = "gen/js";
          description = "Output directory(ies) for generated JavaScript code";
          example = literalExpression ''
            [
              "gen/js"
              "src/proto"
              "packages/frontend/src/proto"
              "packages/backend/src/proto"
            ]
          '';
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

        # ECMAScript modules support with Protobuf-ES (default TypeScript generator)
        es = {
          enable = mkOption {
            type = types.bool;
            default = true; # Enable by default for TypeScript-first development
            description = "Enable ECMAScript modules generation with Protobuf-ES (modern JavaScript/TypeScript)";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-es";
            description = "The protoc-gen-es package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = ["target=ts"]; # Default to TypeScript output
            description = "Options to pass to protoc-gen-es (e.g., target=ts, import_extension=.js)";
          };

          target = mkOption {
            type = types.enum ["js" "ts" "dts"];
            default = "ts";
            description = "Target output format (js, ts, or dts for TypeScript declarations)";
          };

          importExtension = mkOption {
            type = types.str;
            default = ""; # Let protoc-gen-es handle defaults
            description = "Import extension to use (e.g., '.js' for Node.js ES modules)";
          };

          generatePackageJson = mkOption {
            type = types.bool;
            default = false;
            description = "Generate package.json for the generated code";
          };

          packageName = mkOption {
            type = types.str;
            default = "";
            description = "Package name for generated package.json";
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
            type = types.nullOr types.package;
            default = null;
            defaultText = literalExpression "null";
            description = "The protoc-gen-connect-es package to use (deprecated - functionality integrated into protoc-gen-es v2)";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-connect-es";
          };

          generatePackageJson = mkOption {
            type = types.bool;
            default = false;
            description = "Generate package.json for the generated code";
          };

          packageName = mkOption {
            type = types.str;
            default = "";
            description = "Package name for generated package.json";
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
            defaultText = literalExpression "pkgs.protoc-gen-grpc-web";
            description = "The protoc-gen-grpc-web package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-grpc-web";
          };

          importStyle = mkOption {
            type = types.enum ["typescript" "commonjs" "closure"];
            default = "commonjs";
            description = "Import style for generated gRPC-Web code";
          };

          mode = mkOption {
            type = types.enum ["grpcweb" "grpcwebtext"];
            default = "grpcweb";
            description = "gRPC-Web mode (grpcweb or grpcwebtext)";
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

        # Protovalidate support
        protovalidate = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable protovalidate-es validation code generation for JavaScript/TypeScript";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-es";
            description = "The protoc-gen-es package to use (protovalidate-es uses the same generator)";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-es for protovalidate";
          };

          generateValidationHelpers = mkOption {
            type = types.bool;
            default = true;
            description = "Generate validation helper functions";
          };

          target = mkOption {
            type = types.enum ["js" "ts" "dts"];
            default = "ts";
            description = "Target output format (js, ts, or dts for TypeScript declarations)";
          };
        };

        # ts-proto for TypeScript-first development
        tsProto = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable ts-proto TypeScript code generation (idiomatic TypeScript interfaces)";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-ts_proto";
            description = "The ts-proto package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to ts-proto (e.g., esModuleInterop=true, useOptionals=messages)";
          };

          generatePackageJson = mkOption {
            type = types.bool;
            default = false;
            description = "Generate package.json for the generated code";
          };

          generateTsConfig = mkOption {
            type = types.bool;
            default = false;
            description = "Generate tsconfig.json for the generated code";
          };

          packageName = mkOption {
            type = types.str;
            default = "";
            description = "Package name for generated package.json";
          };
        };
      };

      # Java language options
      java = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Java code generation";
        };

        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.protobuf";
          description = "The protobuf package to use for Java generation";
        };

        outputPath = mkOption {
          type = types.either types.str (types.listOf types.str);
          default = "gen/java";
          description = "Output directory(ies) for generated Java code";
          example = literalExpression ''
            [
              "gen/java"
              "src/main/java"
            ]
          '';
        };

        options = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Options to pass to protoc Java plugins";
        };

        packageName = mkOption {
          type = types.str;
          default = "";
          description = "Java package name for generated code";
        };

        jdk = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.jdk17";
          description = "JDK package to use";
        };

        grpc = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC code generation for Java";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.grpc-java";
            description = "The grpc-java package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to the gRPC Java plugin";
          };
        };

        protovalidate = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable protovalidate code generation for Java";
          };

          package = mkOption {
            type = types.package;
            defaultText = literalExpression "pkgs.protoc-gen-validate-java";
            description = "The protovalidate-java plugin package to use";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to the protovalidate Java plugin";
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
          type = types.either types.str (types.listOf types.str);
          default = "lib/proto";
          description = "Output directory(ies) for generated Dart code";
          example = literalExpression ''
            [
              "lib/proto"
              "lib/generated"
            ]
          '';
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
          type = types.either types.str (types.listOf types.str);
          default = "gen/doc";
          description = "Output directory(ies) for generated documentation";
          example = literalExpression ''
            [
              "gen/doc"
              "docs/api"
            ]
          '';
        };

        options = mkOption {
          type = types.listOf types.str;
          default = ["html,index.html"];
          description = "Options to pass to protoc-gen-doc (format,output_file)";
        };

        format = mkOption {
          type = types.enum ["html" "markdown" "json" "docbook" "mdx"];
          default = "html";
          description = "Documentation output format";
        };

        outputFile = mkOption {
          type = types.str;
          default = "index.html";
          description = "Output filename for the documentation";
        };

        customTemplate = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Path to custom template file for documentation generation";
        };

        mdx = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable MDX format generation for Astro documentation site";
          };

          outputFile = mkOption {
            type = types.str;
            default = "api-reference.mdx";
            description = "Output filename for MDX documentation";
          };

          title = mkOption {
            type = types.str;
            default = "API Reference";
            description = "Title for the MDX documentation";
          };

          description = mkOption {
            type = types.str;
            default = "Generated API documentation from Protocol Buffers";
            description = "Description for the MDX documentation";
          };

          frontmatter = mkOption {
            type = types.attrs;
            default = {};
            example = literalExpression ''
              {
                title = "API Reference";
                description = "Protocol Buffer API documentation";
                sidebar.order = 3;
              }
            '';
            description = "Additional frontmatter attributes for MDX files";
          };

          outputPath = mkOption {
            type = types.either types.str (types.listOf types.str);
            default = "./doc/src/content/docs/reference";
            description = "Output directory(ies) for MDX documentation (relative to project root)";
            example = literalExpression ''
              [
                "./doc/src/content/docs/reference"
                "./docs/api"
              ]
            '';
          };
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
          type = types.either types.str (types.listOf types.str);
          default = "gen/svg";
          description = "Output directory(ies) for generated SVG diagrams";
          example = literalExpression ''
            [
              "gen/svg"
              "docs/diagrams"
            ]
          '';
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
          type = types.either types.str (types.listOf types.str);
          default = "gen/python";
          description = "Output directory(ies) for generated Python code";
          example = literalExpression ''
            [
              "gen/python"
              "src/proto"
              "dist/mypackage/proto"
              "tests/fixtures/proto"
            ]
          '';
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
          type = types.either types.str (types.listOf types.str);
          default = "gen/swift";
          description = "Output directory(ies) for generated Swift code";
          example = literalExpression ''
            [
              "gen/swift"
              "Sources/Proto"
            ]
          '';
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

      # C# language options
      csharp = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable C# code generation";
        };

        sdk = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.dotnetCorePackages.sdk_8_0";
          description = "The .NET SDK package to use";
        };

        outputPath = mkOption {
          type = types.either types.str (types.listOf types.str);
          default = "gen/csharp";
          description = "Output directory(ies) for generated C# code";
          example = literalExpression ''
            [
              "gen/csharp"
              "src/Proto"
            ]
          '';
        };

        options = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Options to pass to protoc C# plugin";
        };

        namespace = mkOption {
          type = types.str;
          default = "";
          description = "Base namespace for generated C# code";
        };

        targetFramework = mkOption {
          type = types.str;
          default = "net8.0";
          description = ".NET target framework";
        };

        langVersion = mkOption {
          type = types.str;
          default = "latest";
          description = "C# language version";
        };

        nullable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable nullable reference types";
        };

        fileExtension = mkOption {
          type = types.str;
          default = ".cs";
          description = "File extension for generated files";
        };

        generateProjectFile = mkOption {
          type = types.bool;
          default = true;
          description = "Generate .csproj file for the generated code";
        };

        projectName = mkOption {
          type = types.str;
          default = "GeneratedProtos";
          description = "Name for the generated .csproj file";
        };

        packageId = mkOption {
          type = types.str;
          default = "";
          description = "NuGet package ID if generating a package";
        };

        packageVersion = mkOption {
          type = types.str;
          default = "1.0.0";
          description = "Version for the generated package";
        };

        generatePackageOnBuild = mkOption {
          type = types.bool;
          default = false;
          description = "Generate NuGet package on build";
        };

        generateAssemblyInfo = mkOption {
          type = types.bool;
          default = false;
          description = "Generate AssemblyInfo.cs file";
        };

        assemblyVersion = mkOption {
          type = types.str;
          default = "1.0.0.0";
          description = "Assembly version for generated code";
        };

        protobufVersion = mkOption {
          type = types.str;
          default = "3.31.0";
          description = "Google.Protobuf NuGet package version";
        };

        # gRPC support
        grpc = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC code generation for C#";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to grpc C# plugin";
          };

          grpcVersion = mkOption {
            type = types.str;
            default = "2.72.0";
            description = "Grpc.Net.Client NuGet package version";
          };

          grpcCoreVersion = mkOption {
            type = types.str;
            default = "2.72.0";
            description = "Grpc.Core.Api NuGet package version";
          };

          generateClientFactory = mkOption {
            type = types.bool;
            default = false;
            description = "Generate gRPC client factory classes";
          };

          generateServerBase = mkOption {
            type = types.bool;
            default = false;
            description = "Generate base server implementations";
          };
        };
      };

      # Kotlin language options
      kotlin = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Kotlin code generation (requires Java output as well)";
        };

        jdk = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.jdk17";
          description = "JDK package to use for running Java-based plugins";
        };

        outputPath = mkOption {
          type = types.either types.str (types.listOf types.str);
          default = "gen/kotlin";
          description = "Base output directory(ies) for generated code";
          example = literalExpression ''
            [
              "gen/kotlin"
              "src/main/proto"
            ]
          '';
        };

        javaOutputPath = mkOption {
          type = types.either types.str (types.listOf types.str);
          default = "gen/kotlin/java";
          description = "Output directory(ies) for generated Java code (required for Kotlin)";
          example = literalExpression ''
            [
              "gen/kotlin/java"
              "src/main/java"
            ]
          '';
        };

        kotlinOutputPath = mkOption {
          type = types.either types.str (types.listOf types.str);
          default = "gen/kotlin/kotlin";
          description = "Output directory(ies) for generated Kotlin code";
          example = literalExpression ''
            [
              "gen/kotlin/kotlin"
              "src/main/kotlin"
            ]
          '';
        };

        options = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Options to pass to Kotlin code generation";
        };

        projectName = mkOption {
          type = types.str;
          default = "GeneratedProtos";
          description = "Name for the Kotlin project";
        };

        kotlinVersion = mkOption {
          type = types.str;
          default = "2.1.20";
          description = "Kotlin version to use";
        };

        protobufVersion = mkOption {
          type = types.str;
          default = "4.28.2";
          description = "Google Protobuf version";
        };

        jvmTarget = mkOption {
          type = types.int;
          default = 17;
          description = "JVM target version";
        };

        coroutinesVersion = mkOption {
          type = types.str;
          default = "1.8.0";
          description = "Kotlin coroutines version";
        };

        generateBuildFile = mkOption {
          type = types.bool;
          default = true;
          description = "Generate build.gradle.kts file";
        };

        generatePackageInfo = mkOption {
          type = types.bool;
          default = false;
          description = "Generate package-info.java files";
        };

        # gRPC support
        grpc = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC code generation for Kotlin";
          };

          grpcVersion = mkOption {
            type = types.str;
            default = "1.62.2";
            description = "gRPC Java version";
          };

          grpcKotlinVersion = mkOption {
            type = types.str;
            default = "1.4.2";
            description = "gRPC Kotlin version";
          };

          grpcKotlinJar = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to gRPC Kotlin plugin JAR (will download if not provided)";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to gRPC Kotlin plugin";
          };

          generateServiceImpl = mkOption {
            type = types.bool;
            default = false;
            description = "Generate service implementation stubs";
          };
        };

        # Connect RPC support
        connect = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Connect RPC code generation for Kotlin";
          };

          connectVersion = mkOption {
            type = types.str;
            default = "0.7.3";
            description = "Connect Kotlin version";
          };

          connectKotlinJar = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to Connect Kotlin plugin JAR (will download if not provided)";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to Connect Kotlin plugin";
          };

          packageName = mkOption {
            type = types.str;
            default = "com.example.connect";
            description = "Package name for generated Connect configuration";
          };

          generateClientConfig = mkOption {
            type = types.bool;
            default = false;
            description = "Generate Connect client configuration helper";
          };
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
          type = types.either types.str (types.listOf types.str);
          default = "gen/c";
          description = "Output directory(ies) for generated C code";
          example = literalExpression ''
            [
              "gen/c"
              "src/proto"
            ]
          '';
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
            type = types.either types.str (types.listOf types.str);
            default = "gen/c/protobuf-c";
            description = "Output directory(ies) for generated protobuf-c code";
            example = literalExpression ''
              [
                "gen/c/protobuf-c"
                "src/proto/c"
              ]
            '';
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
            type = types.either types.str (types.listOf types.str);
            default = "gen/c/nanopb";
            description = "Output directory(ies) for generated nanopb code";
            example = literalExpression ''
              [
                "gen/c/nanopb"
                "embedded/proto"
              ]
            '';
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
            type = types.either types.str (types.listOf types.str);
            default = "gen/c/upb";
            description = "Output directory(ies) for generated upb code";
            example = literalExpression ''
              [
                "gen/c/upb"
                "src/proto/upb"
              ]
            '';
          };

          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Options to pass to protoc-gen-upb";
          };
        };
      };
      
      # Scala language options
      scala = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Scala code generation";
        };
        
        package = mkOption {
          type = types.package;
          defaultText = literalExpression "pkgs.scalapb";
          description = "The ScalaPB package to use";
        };
        
        outputPath = mkOption {
          type = types.either types.str (types.listOf types.str);
          default = "gen/scala";
          description = "Output directory(ies) for generated Scala code";
          example = literalExpression ''
            [
              "gen/scala"
              "src/main/scala"
            ]
          '';
        };
        
        options = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Options to pass to ScalaPB";
        };
        
        scalaVersion = mkOption {
          type = types.str;
          default = "3.3.3";
          description = "Scala version for generated build file";
        };
        
        scalapbVersion = mkOption {
          type = types.str;
          default = "1.0.0-alpha.1";
          description = "ScalaPB version";
        };
        
        sbtVersion = mkOption {
          type = types.str;
          default = "1.10.5";
          description = "SBT version for generated build file";
        };
        
        sbtProtocVersion = mkOption {
          type = types.str;
          default = "1.0.7";
          description = "sbt-protoc plugin version";
        };
        
        projectName = mkOption {
          type = types.str;
          default = "generated-protos";
          description = "Project name for generated build file";
        };
        
        projectVersion = mkOption {
          type = types.str;
          default = "0.1.0";
          description = "Project version for generated build file";
        };
        
        organization = mkOption {
          type = types.str;
          default = "com.example";
          description = "Organization for generated build file";
        };
        
        generateBuildFile = mkOption {
          type = types.bool;
          default = false;
          description = "Generate build.sbt file";
        };
        
        generatePackageObject = mkOption {
          type = types.bool;
          default = false;
          description = "Generate package objects for proto packages";
        };
        
        # gRPC support
        grpc = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gRPC code generation for Scala";
          };
          
          options = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Additional options for gRPC generation";
          };
        };
        
        # JSON support
        json = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable JSON serialization support";
          };
          
          json4sVersion = mkOption {
            type = types.str;
            default = "0.7.0";
            description = "scalapb-json4s version";
          };
        };
        
        # Validation support
        validate = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable validation support (scalapb-validate)";
          };
        };
      };
    };
  };
}
