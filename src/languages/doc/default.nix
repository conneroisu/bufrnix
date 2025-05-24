{
  pkgs,
  config,
  lib,
  cfg ? config.languages.doc,
  ...
}:
with lib; let
  cfg = config.languages.doc;
in {
  runtimeInputs = [
    pkgs.protoc-gen-doc
  ];

  protocPlugins = [
    "--doc_out=${cfg.outputPath}"
  ];

  commandOptions = [
    "--doc_opt=${concatStringsSep "," cfg.options}"
  ];

  initHooks = ''
    echo "Initializing doc code generation..."
    mkdir -p "${cfg.outputPath}"
  '';

  generateHooks = ''
    echo "Generated doc code in ${cfg.outputPath}"
  '';
}
