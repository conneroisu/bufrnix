# ProtoValidate for Go: https://github.com/bufbuild/protovalidate-go
{
  pkgs,
  config,
  lib,
  debug,
  ...
}:
with lib; let
  cfg = config.languages.go.validate;
  goCfg = config.languages.go;
  debugUtils = debug;
in {
  options.languages.go.validate = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable protoc-gen-validate for Go";
    };

    options = mkOption {
      type = types.listOf types.str;
      default = ["lang=go"];
      description = "Options to pass to protoc-gen-validate";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.protoc-gen-validate or null;
      description = "The package that provides the protoc-gen-validate binary";
    };
  };

  # Define the implementation that gets used by mkBufrnix.nix
  config = mkIf (goCfg.enable && cfg.enable) {
    # Add the validate plugin to runtime inputs
    buildInputs = mkIf (cfg.package != null) [
      cfg.package
    ];

    # Add validate-specific command generation functions
    protocCommands = mkIf (cfg.package != null) {
      # Function to generate validate-specific protoc flags
      mkValidateFlags = ''
        # Add validation plugin flags
        protoc_flags+=(
          "--validate_out=${goCfg.outputPath}"
          ${concatMapStrings (opt: "--validate_opt=${opt} ") cfg.options}
        )
        ${debugUtils.log 2 "Added validation flags to protoc command" config}
      '';
    };

    # Add hooks for post-processing if needed
    postGenerate = mkIf (cfg.package != null) ''
      ${debugUtils.log 2 "Validation code generation completed" config}
    '';
  };
}
