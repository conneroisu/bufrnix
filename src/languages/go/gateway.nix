# gRPC Gateway for Go: https://github.com/grpc-ecosystem/grpc-gateway
{
  pkgs,
  config,
  lib,
  debug,
  ...
}:
with lib; let
  cfg = config.languages.go.gateway;
  goCfg = config.languages.go;
  debugUtils = debug;
in {
  options.languages.go.gateway = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable gRPC Gateway code generation for Go";
    };

    options = mkOption {
      type = types.listOf types.str;
      default = ["paths=source_relative"];
      description = "Options to pass to protoc-gen-grpc-gateway";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.grpc-gateway or null;
      description = "The package that provides the protoc-gen-grpc-gateway binary";
    };
    
    standalone = mkOption {
      type = types.bool;
      default = false;
      description = "Generate Gateway code without requiring gRPC service implementation";
    };
  };

  # Define the implementation that gets used by mkBufrnix.nix
  config = mkIf (goCfg.enable && cfg.enable) {
    # Verify that gRPC is enabled if gateway is not standalone
    warnings = mkIf (!cfg.standalone && !goCfg.grpc.enable) [
      "Go gRPC Gateway is enabled but gRPC is not. Gateway generation may fail. Set languages.go.gateway.standalone = true for standalone gateway."
    ];

    # Add the gateway plugin to runtime inputs
    buildInputs = mkIf (cfg.package != null) [
      cfg.package
    ];

    # Add gateway-specific command generation functions
    protocCommands = mkIf (cfg.package != null) {
      # Function to generate gateway-specific protoc flags
      mkGatewayFlags = ''
        # Add gRPC Gateway plugin flags
        protoc_flags+=(
          "--grpc-gateway_out=${goCfg.outputPath}"
          ${concatMapStrings (opt: "--grpc-gateway_opt=${opt} ") cfg.options}
        )
        ${debugUtils.log 2 "Added gRPC Gateway flags to protoc command" config}
      '';
    };

    # Add hooks for post-processing if needed
    postGenerate = mkIf (cfg.package != null) ''
      ${debugUtils.log 2 "gRPC Gateway code generation completed" config}
    '';
  };
}
