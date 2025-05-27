{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "gen/c/protobuf-c";
  options = cfg.options or [];
in {
  runtimeInputs = optionals enabled [
    (cfg.package or pkgs.protobuf-c)
  ];

  protocPlugins =
    optionals enabled [
      "--c_out=${outputPath}"
    ]
    ++ optionals (length options > 0) [
      "--c_opt=${concatStringsSep " --c_opt=" options}"
    ];

  initHooks = optionalString enabled ''
    echo "Setting up protobuf-c generation..."
    mkdir -p "${outputPath}"
  '';

  generateHooks = optionalString enabled ''
    echo "Generating protobuf-c code..."
  '';
}
