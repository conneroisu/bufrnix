{
  pkgs,
  config,
  lib,
  cfg ? config.languages.doc,
  ...
}:
with lib; let
  cfg = config.languages.doc;
  # Build the doc_opt string from format and outputFile if options is empty
  docOptions = if cfg.options == [] 
    then "${cfg.format},${cfg.outputPath}/${cfg.outputFile}"
    else concatStringsSep "," cfg.options;
in {
  runtimeInputs = [
    cfg.package
  ];

  protocPlugins = [
    "--doc_out=${cfg.outputPath}"
    "--doc_opt=${cfg.format},${cfg.outputFile}"
  ];

  commandOptions = [];

  initHooks = ''
    echo "Initializing doc code generation..."
    mkdir -p "${cfg.outputPath}"
  '';

  generateHooks = ''
    mkdir -p "${cfg.outputPath}"
    echo "Generating documentation to ${cfg.outputPath}/${cfg.outputFile}"
  '';
}
