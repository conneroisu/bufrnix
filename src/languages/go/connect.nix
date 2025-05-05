# Connect-Go RPC: https://connectrpc.com/
{
  pkgs,
  config,
  lib,
  debug,
  ...
}:
with lib; let
  cfg = config.languages.go.connect;
  goCfg = config.languages.go;
  debugUtils = debug;
in {
  options.languages.go.connect = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Connect-Go code generation";
    };

    options = mkOption {
      type = types.listOf types.str;
      default = ["paths=source_relative"];
      description = "Options to pass to protoc-gen-connect-go";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.protoc-gen-connect-go or null;
      description = "The package that provides the protoc-gen-connect-go binary";
    };
  };

  # Define the implementation that gets used by mkBufrnix.nix
  config = mkIf (goCfg.enable && cfg.enable) {
    # Add the Connect-Go plugin to runtime inputs
    buildInputs = mkIf (cfg.package != null) [
      cfg.package
    ];

    # Add Connect-Go-specific command generation functions
    protocCommands = mkIf (cfg.package != null) {
      # Function to generate Connect-specific protoc flags
      mkConnectFlags = ''
        # Add Connect-Go plugin flags
        protoc_flags+=(
          "--connect-go_out=${goCfg.outputPath}"
          ${concatMapStrings (opt: "--connect-go_opt=${opt} ") cfg.options}
        )
        ${debugUtils.log 2 "Added Connect-Go flags to protoc command" config}
      '';
    };

    # Add hooks for post-processing if needed
    postGenerate = mkIf (cfg.package != null) ''
      ${debugUtils.log 2 "Connect-Go code generation completed" config}
    '';
  };
}
