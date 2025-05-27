{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "gen/go";
  options = cfg.options or ["paths=source_relative"];
in {
  # Runtime dependencies for gRPC Federation
  runtimeInputs = optionals enabled [
    cfg.package or pkgs.protoc-gen-grpc-federation
  ];

  # Protoc plugin configuration for gRPC Federation
  protocPlugins = optionals enabled [
    "--grpc-federation_out=${outputPath}"
    "--grpc-federation_opt=${concatStringsSep " --grpc-federation_opt=" options}"
  ];

  # Initialization hooks for gRPC Federation
  initHooks = optionalString enabled ''
    echo "Setting up gRPC Federation generation..."
    echo "NOTE: gRPC Federation is an experimental feature"
    echo "This enables automatic BFF server generation"
  '';

  # Generation hooks for gRPC Federation
  generateHooks = optionalString enabled ''
    echo "Configuring gRPC Federation generation..."
    echo "gRPC Federation requires additional configuration in proto files"
  '';
}
