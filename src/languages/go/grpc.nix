{
  pkgs,
  config,
  lib,
  debug,
  ...
}:
with lib; let
  cfg = config.languages.go;
  debugUtils = debug;
in {
  options.languages.go.grpc = {
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

    package = mkOption {
      type = types.package;
      default = pkgs.protoc-gen-go-grpc;
      description = "The package that provides the protoc-gen-go-grpc binary";
    };
  };

  # Define the implementation that gets used by mkBufrnix.nix
  config = mkIf (cfg.enable && cfg.grpc.enable) {
    # Add the gRPC plugin to runtime inputs
    buildInputs = [
      cfg.grpc.package
    ];

    # Add Go gRPC-specific command generation functions
    protocCommands = {
      # Function to generate gRPC-specific protoc flags
      mkGrpcFlags = ''
        # Add Go gRPC plugin flags
        protoc_flags+=(
          "--go-grpc_out=${cfg.outputPath}"
          ${concatMapStrings (opt: "--go-grpc_opt=${opt} ") cfg.grpc.options}
        )
        ${debugUtils.log 2 "Added Go gRPC flags to protoc command" config}
      '';

      # Function to prepare output directories
      prepareGrpcDirs = ''
        # Ensure Go gRPC output directory exists
        mkdir -p ${cfg.outputPath}
        ${debugUtils.log 2 "Created gRPC output directory: ${cfg.outputPath}" config}
      '';
    };

    # Add hooks for post-processing if needed
    postGenerate = ''
      ${debugUtils.log 2 "Go gRPC code generation completed" config}
    '';
  };
}
