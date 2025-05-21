{
  pkgs,
  config,
  lib,
  cfg ? config.languages.dart,
  ...
}:
with lib; let
  # Define output path and options
  outputPath = cfg.outputPath;
  dartOptions = cfg.options;

  # Import Dart-specific sub-modules
  grpcModule = import ./grpc.nix {
    inherit pkgs lib;
    cfg =
      (cfg.grpc or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  # Combine all sub-modules
  combineModuleAttrs = attr:
    concatLists (catAttrs attr [
      grpcModule
    ]);
in {
  # Runtime dependencies for Dart code generation
  runtimeInputs =
    [
      pkgs.protoc-gen-dart
    ]
    ++ (combineModuleAttrs "runtimeInputs");

  # Protoc plugin configuration for Dart
  protocPlugins =
    [
      "--dart_out=${outputPath}"
    ]
    ++ (optionals (dartOptions != []) [
      "--dart_opt=${concatStringsSep " --dart_opt=" dartOptions}"
    ])
    ++ (combineModuleAttrs "protocPlugins");

  # Initialization hook for Dart
  initHooks =
    ''
      # Create dart-specific directories
      mkdir -p "${outputPath}"
      ${optionalString (cfg.packageName != "") ''
        echo "Creating Dart package: ${cfg.packageName}"
      ''}
    ''
    + concatStrings (catAttrs "initHooks" [
      grpcModule
    ]);

  # Code generation hook for Dart
  generateHooks =
    ''
      # Dart-specific code generation steps
      echo "Generating Dart code..."
      mkdir -p ${outputPath}
    ''
    + concatStrings (catAttrs "generateHooks" [
      grpcModule
    ]);
}