{
  pkgs,
  config,
  lib,
  cfg ? config.languages.svg,
  ...
}:
with lib; let
  cfg = config.languages.svg;

  # Build command options string
  optionsStr =
    if cfg.options != []
    then concatStringsSep " " (map (opt: "--d2_opt=${opt}") cfg.options)
    else "";
in {
  runtimeInputs = [
    cfg.package
    pkgs.d2 # D2 runtime dependency for rendering
  ];

  protocPlugins =
    [
      "--plugin=protoc-gen-d2=${cfg.package}/bin/protoc-gen-d2"
      "--d2_out=${cfg.outputPath}"
    ]
    ++ (
      if optionsStr != ""
      then ["--d2_opt=${optionsStr}"]
      else []
    );

  commandOptions = [];

  initHooks = ''
    echo "Initializing SVG diagram generation..."
    mkdir -p "${cfg.outputPath}"
  '';

  generateHooks = ''
    mkdir -p "${cfg.outputPath}"
    echo "Generating SVG diagrams to ${cfg.outputPath}"

    # Post-process to ensure SVG files are generated
    if command -v d2 >/dev/null 2>&1; then
      for d2_file in "${cfg.outputPath}"/*.d2; do
        if [ -f "$d2_file" ]; then
          base_name=$(basename "$d2_file" .d2)
          echo "Rendering $base_name.d2 to SVG..."
          d2 "$d2_file" "${cfg.outputPath}/$base_name.svg" || true
        fi
      done
    fi
  '';
}
