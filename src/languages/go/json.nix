{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "gen/go";
  options =
    cfg.options or [
      "paths=source_relative"
      "orig_name=true"
    ];
in {
  # Runtime dependencies for go-json
  runtimeInputs = optionals enabled [
    cfg.package or (pkgs.callPackage ../../packages/protoc-gen-go-json.nix {})
  ];

  # Protoc plugin configuration for go-json
  protocPlugins = optionals enabled [
    "--go-json_out=${outputPath}"
    "--go-json_opt=${concatStringsSep " --go-json_opt=" options}"
  ];

  # Initialization hooks for go-json
  initHooks = optionalString enabled ''
    echo "Setting up Go JSON generation..."
    echo "This enables seamless integration with encoding/json"
  '';

  # Generation hooks for go-json
  generateHooks = optionalString enabled ''
    echo "Configuring Go JSON generation..."
  '';
}
