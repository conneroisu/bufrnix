{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "lib/proto";
  options = cfg.options or [];
in {
  # Runtime dependencies for gRPC
  runtimeInputs = optionals enabled [
    # protoc-gen-dart includes both grpc and protobuf support
    cfg.package or pkgs.protoc-gen-dart
  ];

  # Protoc plugin configuration for gRPC
  # Note: The main dart plugin handles basic generation with the dart_out option
  protocPlugins = optionals enabled [
    # The protoc-gen-dart plugin handles both protobuf and gRPC code generation
    # Additional gRPC options could be added here if needed
  ];

  # Initialization hooks for gRPC
  initHooks = optionalString enabled ''
    echo "Setting up Dart gRPC generation..."
  '';

  # Generation hooks for gRPC
  generateHooks = optionalString enabled ''
    echo "Configuring Dart gRPC generation..."
  '';
}
