{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "gen/openapi";
  options = cfg.options or ["logtostderr=true"];
in {
  # Runtime dependencies for OpenAPI v2
  runtimeInputs = optionals enabled [
    cfg.package or (pkgs.callPackage ../../packages/protoc-gen-openapiv2.nix {})
  ];

  # Protoc plugin configuration for OpenAPI v2
  protocPlugins = optionals enabled [
    "--openapiv2_out=${outputPath}"
    "--openapiv2_opt=${concatStringsSep " --openapiv2_opt=" options}"
  ];

  # Initialization hooks for OpenAPI v2
  initHooks = optionalString enabled ''
    echo "Setting up OpenAPI v2 generation..."
    mkdir -p "${outputPath}"
  '';

  # Generation hooks for OpenAPI v2
  generateHooks = optionalString enabled ''
    echo "Configuring OpenAPI v2 generation..."
  '';
}
