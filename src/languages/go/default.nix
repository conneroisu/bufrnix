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
  options.languages.go = {
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

    package = mkOption {
      type = types.package;
      default = pkgs.protoc-gen-go;
      description = "The package that provides the protoc-gen-go binary";
    };
    
    # Import nested options from submodules
    imports = [
      ./grpc.nix
      ./connect.nix
      ./validate.nix
    ];
  };

  # Define the implementation that gets used by mkBufrnix.nix
  config = mkIf cfg.enable {
    # Add the Go plugin to runtime inputs
    buildInputs = [
      cfg.package
    ];

    # Add Go-specific command generation functions
    protocCommands = {
      # Function to generate Go-specific protoc flags
      mkGoFlags = ''
        # Add Go plugin flags
        protoc_flags+=(
          "--go_out=${cfg.outputPath}"
          ${concatMapStrings (opt: "--go_opt=${opt} ") cfg.options}
        )
        ${debugUtils.log 2 "Added Go flags to protoc command" config}
      '';

      # Function to prepare output directories
      prepareGoDirs = ''
        # Ensure Go output directory exists
        mkdir -p ${cfg.outputPath}
        ${debugUtils.log 2 "Created Go output directory: ${cfg.outputPath}" config}
      '';
    };

    # Add post-processing hook to support package prefix if configured
    postGenerate = ''
      ${optionalString (cfg.packagePrefix != "") ''
        # Update Go package prefixes if needed
        echo "Updating Go package prefixes with '${cfg.packagePrefix}'"
        find ${cfg.outputPath} -name "*.go" -type f -exec sed -i "s#package \\(.*\\)#package ${cfg.packagePrefix}\\1#g" {} \;
        ${debugUtils.log 2 "Updated Go package prefixes with '${cfg.packagePrefix}'" config}
      ''}
    '';

    # Pre-generation validation to ensure proper configuration
    preGenerate = ''
      ${debugUtils.log 1 "Starting Go code generation" config}
      
      # Validate Go generation configuration
      if [ ! -d "${config.root}" ]; then
        ${debugUtils.enhanceError "Root directory '${config.root}' does not exist" 1}
      fi
      
      ${debugUtils.log 2 "Go generation configuration validated" config}
    '';
  };
}