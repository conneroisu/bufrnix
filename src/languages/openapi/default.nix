{
  pkgs,
  config, # Added config
  lib,
  cfg ? config.languages.openapi, # Updated cfg definition
  ...
}:
with lib; let
  # cfg is already defined in the arguments, no need to redefine
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "gen/openapi";
  options = cfg.options or ["logtostderr=true"];
in {
  # Runtime dependencies for OpenAPI v2
  runtimeInputs = optionals enabled [
    cfg.package or (pkgs.callPackage ../../packages/protoc-gen-openapiv2 {})
  ];

  # Protoc plugin configuration for OpenAPI v2
  protocPlugins = optionals enabled (
    let
      # Ensure options is a list for concatStringsSep
      safeOptions = if isList options then options else [options];
    in
    [
      "--openapiv2_out=${outputPath}"
    ] ++ (
      if safeOptions != [] then # Corrected typo here
        ["--openapiv2_opt=${concatStringsSep "," safeOptions}"]
      else []
    )
  );

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
