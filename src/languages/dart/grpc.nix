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
  ];

  # Protoc plugin configuration for gRPC
  # Note: gRPC generation is handled in the main dart module
  protocPlugins = [];

  # Initialization hooks for gRPC
  initHooks = optionalString enabled ''
    echo "Setting up Dart gRPC generation..."
  '';

  # Generation hooks for gRPC
  generateHooks = optionalString enabled ''
    echo "Configuring Dart gRPC generation..."
  '';
}