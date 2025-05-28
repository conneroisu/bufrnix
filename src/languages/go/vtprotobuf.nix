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
      "features=marshal+unmarshal+size"
    ];
in {
  # Runtime dependencies for vtprotobuf
  runtimeInputs = optionals enabled [
    cfg.package or pkgs.protoc-gen-go-vtproto
  ];

  # Protoc plugin configuration for vtprotobuf
  protocPlugins = optionals enabled [
    "--go-vtproto_out=${outputPath}"
    "--go-vtproto_opt=${concatStringsSep " --go-vtproto_opt=" options}"
  ];

  # Initialization hooks for vtprotobuf
  initHooks = optionalString enabled ''
    echo "Setting up Go vtprotobuf generation..."
    echo "vtprotobuf provides high-performance marshaling (3.8x faster)"
  '';

  # Generation hooks for vtprotobuf
  generateHooks = optionalString enabled ''
    echo "Configuring Go vtprotobuf generation..."
  '';
}
