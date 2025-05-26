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
  # Runtime dependencies for gRPC
  runtimeInputs = optionals enabled [
    cfg.package or pkgs.protoc-gen-go-grpc
  ];

  # Protoc plugin configuration for gRPC
  protocPlugins = optionals enabled [
    "--go-grpc_out=${outputPath}"
    "--go-grpc_opt=${concatStringsSep " --go-grpc_opt=" options}"
  ];

  # Initialization hooks for gRPC
  initHooks = optionalString enabled ''
    echo "Setting up Go gRPC generation..."
  '';

  # Generation hooks for gRPC
  generateHooks = optionalString enabled ''
    echo "Configuring Go gRPC generation..."
  '';
}
