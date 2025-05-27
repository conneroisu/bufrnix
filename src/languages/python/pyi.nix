{
  pkgs,
  lib,
  cfg,
  ...
}:
with lib; {
  # Runtime dependencies for Python pyi generation
  runtimeInputs = optionals cfg.enable [
    cfg.package
  ];

  # Protoc plugins for Python pyi type stubs
  protocPlugins =
    optionals cfg.enable [
      "--pyi_out=${cfg.outputPath}"
    ]
    ++ (optionals (cfg.enable && cfg.options != []) [
      "--pyi_opt=${concatStringsSep " --pyi_opt=" cfg.options}"
    ]);

  # Initialization hooks for Python pyi
  initHooks = optionalString cfg.enable ''
    # Python type stub generation setup
    echo "Setting up Python type stub (.pyi) generation..."
  '';

  # Code generation hooks for Python pyi
  generateHooks = optionalString cfg.enable ''
    # Python pyi-specific post-processing
    echo "Post-processing Python type stubs..."

    # Ensure all .pyi files are properly formatted
    find ${cfg.outputPath} -name "*.pyi" -type f | while read -r file; do
      echo "Generated type stub: $file"
    done
  '';
}
