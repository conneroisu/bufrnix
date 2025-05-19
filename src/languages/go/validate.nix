{
  pkgs,
  lib,
  cfg ? {},
  ...
}:

with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "gen/go";
  options = cfg.options or ["lang=go"];
in {
  # Runtime dependencies for Validate
  runtimeInputs = optionals enabled [
    pkgs.protoc-gen-validate or pkgs.go
  ];

  # Protoc plugin configuration for Validate
  protocPlugins = optionals enabled [
    "--validate_out=${outputPath}"
    "--validate_opt=${concatStringsSep " --validate_opt=" options}"
  ];

  # Initialization hooks for Validate
  initHooks = optionalString enabled ''
    echo "Setting up Go Validate generation..."
  '';

  # Generation hooks for Validate
  generateHooks = optionalString enabled ''
    echo "Configuring Go Validate generation..."
  '';
}