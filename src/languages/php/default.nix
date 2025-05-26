{
  pkgs,
  config,
  lib,
  cfg ? config.languages.php,
  ...
}:
with lib; let
  # Define output path and options
  outputPath = cfg.outputPath;
  phpOptions = cfg.options;

  # Import PHP-specific sub-modules
  twirpModule = import ./twirp.nix {
    inherit pkgs lib;
    cfg =
      cfg.twirp
      // {
        outputPath = outputPath;
      };
  };

  # Combine all sub-modules
  combineModuleAttrs = attr:
    concatLists (catAttrs attr [
      twirpModule
    ]);
in {
  # Runtime dependencies for PHP code generation
  runtimeInputs =
    [
      # Base PHP dependencies
      cfg.package
    ]
    ++ (combineModuleAttrs "runtimeInputs");

  # Protoc plugin configuration for PHP
  protocPlugins =
    [
      "--php_out=${outputPath}"
    ]
    ++ (combineModuleAttrs "protocPlugins");

  # Initialization hook for PHP
  initHooks =
    ''
      # Create php-specific directories
      mkdir -p "${outputPath}"
      ${optionalString (cfg.namespace != "") ''
        echo "Creating PHP namespace: ${cfg.namespace}"
      ''}
    ''
    + concatStrings (catAttrs "initHooks" [
      twirpModule
    ]);

  # Code generation hook for PHP
  generateHooks =
    ''
      # PHP-specific code generation steps
      echo "Generating PHP code..."
      mkdir -p ${outputPath}
    ''
    + concatStrings (catAttrs "generateHooks" [
      twirpModule
    ]);
}
