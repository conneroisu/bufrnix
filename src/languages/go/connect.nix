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
  # Runtime dependencies for Connect
  runtimeInputs = optionals enabled [
    pkgs.protoc-gen-connect-go or pkgs.go
  ];

  # Protoc plugin configuration for Connect
  protocPlugins = optionals enabled [
    "--connect-go_out=${outputPath}"
    "--connect-go_opt=${concatStringsSep " --connect-go_opt=" options}"
  ];

  # Initialization hooks for Connect
  initHooks = optionalString enabled ''
    echo "Setting up Go Connect generation..."
  '';

  # Generation hooks for Connect
  generateHooks = optionalString enabled ''
    echo "Configuring Go Connect generation..."
  '';
}