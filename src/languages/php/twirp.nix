{
  pkgs,
  lib, 
  cfg,
  ...
}:

with lib;

let
  enabled = cfg.enable;
  outputPath = cfg.outputPath;
  twirpOptions = cfg.options;
in {
  # Runtime dependencies for Twirp PHP
  runtimeInputs = optionals enabled [
    pkgs.protoc-gen-twirp_php
  ];

  # Protoc plugin configuration for Twirp PHP
  protocPlugins = optionals enabled [
    "--twirp_php_out=${outputPath}"
    "${optionalString (length twirpOptions > 0) "--twirp_php_opt=${concatStringsSep " --twirp_php_opt=" twirpOptions}"}"
  ];

  # Initialization hooks for Twirp PHP
  initHooks = optionalString enabled ''
    # Twirp PHP initialization
    echo "Setting up Twirp PHP in ${outputPath}..."
    mkdir -p "${outputPath}"
  '';

  # Code generation hooks for Twirp PHP
  generateHooks = optionalString enabled ''
    # Twirp PHP code generation
    echo "Generating Twirp PHP code..."
    mkdir -p "${outputPath}"
  '';
}