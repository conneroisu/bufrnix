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
      go = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Go code generation";
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

          options = mkOption {
            type = types.listOf types.str;
            default = ["paths=source_relative"];
            description = "Options to pass to protoc-gen-go-grpc";
          };
        };
      };
    };
  };
}
