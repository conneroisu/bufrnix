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

  # Determine the dart_out option based on whether gRPC is enabled
  dartOutOption =
    if (cfg.grpc.enable or false)
    then "grpc:${outputPath}"
    else "${outputPath}";

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

  protocPlugins =
    [
      "--dart_out=${dartOutOption}"
    ]
    ++ (optionals (dartOptions != []) [
      "--dart_opt=${concatStringsSep " --dart_opt=" dartOptions}"
    ]);

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
