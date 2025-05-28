{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "gen/go";
  # protovalidate doesn't generate code, it's a runtime validation library
  # The proto files just need to be available during compilation
in {
  # Runtime dependencies for protovalidate
  runtimeInputs = optionals enabled [
    # We need the protovalidate proto files available
    cfg.package or pkgs.protovalidate-go
  ];

  # Protoc plugin configuration for protovalidate
  # protovalidate doesn't have a protoc plugin - it uses proto extensions
  protocPlugins = [];

  # Initialization hooks for protovalidate
  initHooks = optionalString enabled ''
    echo "Setting up Go protovalidate support..."
    # protovalidate uses runtime validation, no code generation needed
  '';

  # Generation hooks for protovalidate
  generateHooks = optionalString enabled ''
    echo "Configuring Go protovalidate support..."
    # Ensure protovalidate proto files are in the proto path
  '';
}
