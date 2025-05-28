{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "gen/go";
  goRepoPackage = cfg.goRepoPackage or "models";
  goProtobufPackage = cfg.goProtobufPackage or "proto";
  goModelsFilePath = cfg.goModelsFilePath or "models/models.go";
  outputPackage = cfg.outputPackage or "transform";
in {
  # Runtime dependencies for struct-transformer
  runtimeInputs = optionals enabled [
    cfg.package or (pkgs.callPackage ./protoc-gen-struct-transformer.nix {})
  ];

  # Protoc plugin configuration for struct-transformer
  protocPlugins = optionals enabled [
    "--go_opt=Moptions/annotations.proto=github.com/bold-commerce/protoc-gen-struct-transformer/options"
    "--struct-transformer_out=package=${outputPackage}:${outputPath}"
  ];

  # Initialization hooks for struct-transformer
  initHooks = optionalString enabled ''
    echo "Setting up Go struct-transformer generation..."
    echo "Generating transformation functions between protobuf and business logic structs"
    echo "Models file path: ${goModelsFilePath}"
    echo "Output package: ${outputPackage}"

    # Create the models directory if it doesn't exist
    mkdir -p "$(dirname "${goModelsFilePath}")"
  '';

  # Generation hooks for struct-transformer
  generateHooks = optionalString enabled ''
    echo "Configuring Go struct-transformer generation..."
    echo "Repository package: ${goRepoPackage}"
    echo "Protobuf package: ${goProtobufPackage}"
  '';

  # Special handling for struct-transformer annotations
  extraProtoIncludes = optionals enabled [
    # The struct-transformer plugin requires specific annotation proto files
    # In a real implementation, these would need to be provided
    # For now, we indicate they're needed
  ];

  # Additional setup for struct-transformer specific requirements
  extraSetup = optionalString enabled ''
    # struct-transformer requires access to business logic source files
    # This is a unique requirement compared to other protoc plugins
    # The plugin needs to parse Go source files to understand struct definitions

    # In a production implementation, we would need to:
    # 1. Copy business logic source files into the build environment
    # 2. Ensure the annotation proto files are available
    # 3. Set up proper import paths for the plugin

    echo "Note: struct-transformer requires business logic source files to be available during generation"
    echo "Ensure ${goModelsFilePath} contains the target struct definitions"
    echo "See https://github.com/conneroisu/bufr.nix/examples/go-struct-transformer for an example"
  '';
}
