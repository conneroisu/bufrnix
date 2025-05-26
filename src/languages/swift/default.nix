{
  pkgs,
  config,
  lib,
  cfg ? config.languages.swift,
  ...
}:
with lib; let
  # Define output path and options
  outputPath = cfg.outputPath;
  swiftOptions = cfg.options;

  # Construct swift_out option
  swiftOutOption = "${outputPath}";
in {
  # Runtime dependencies for Swift code generation
  runtimeInputs = [
    cfg.package
  ];

  protocPlugins =
    [
      "--swift_out=${swiftOutOption}"
    ]
    ++ (optionals (swiftOptions != []) [
      "--swift_opt=${concatStringsSep " --swift_opt=" swiftOptions}"
    ]);

  # Initialization hook for Swift
  initHooks = ''
    # Create swift-specific directories
    mkdir -p "${outputPath}"
    ${optionalString (cfg.packageName != "") ''
      echo "Creating Swift package: ${cfg.packageName}"
    ''}
  '';

  # Code generation hook for Swift
  generateHooks = ''
    # Swift-specific code generation steps
    echo "Generating Swift code..."
    mkdir -p ${outputPath}
  '';
}
