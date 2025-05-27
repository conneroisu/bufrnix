{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "gen/c/nanopb";
  options = cfg.options or [];

  # Build nanopb-specific options
  nanopbOptions =
    options
    ++ optionals (cfg.maxSize != 1024) [
      "max_size=${toString cfg.maxSize}"
    ]
    ++ optionals cfg.fixedLength [
      "fixed_length=true"
    ]
    ++ optionals cfg.noUnions [
      "no_unions=true"
    ]
    ++ optionals (cfg.msgidType != "") [
      "msgid_type=${cfg.msgidType}"
    ];
in {
  runtimeInputs = optionals enabled [
    (cfg.package or pkgs.nanopb)
  ];

  protocPlugins =
    optionals enabled [
      "--nanopb_out=${outputPath}"
    ]
    ++ optionals (length nanopbOptions > 0) [
      "--nanopb_opt=${concatStringsSep "," nanopbOptions}"
    ];

  initHooks = optionalString enabled ''
    echo "Setting up nanopb generation..."
    mkdir -p "${outputPath}"
  '';

  generateHooks = optionalString enabled ''
    echo "Generating nanopb code..."
  '';
}
