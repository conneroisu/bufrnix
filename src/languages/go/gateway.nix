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
  # Runtime dependencies for Gateway
  runtimeInputs = optionals enabled [
    pkgs.grpc-gateway or pkgs.go
  ];

  # Protoc plugin configuration for Gateway
  protocPlugins = optionals enabled [
    "--grpc-gateway_out=${outputPath}"
    "--grpc-gateway_opt=${concatStringsSep " --grpc-gateway_opt=" options}"
  ];

  # Initialization hooks for Gateway
  initHooks = optionalString enabled ''
    echo "Setting up Go gRPC-Gateway generation..."
  '';

  # Generation hooks for Gateway
  generateHooks = optionalString enabled ''
    echo "Configuring Go gRPC-Gateway generation..."
  '';
}
