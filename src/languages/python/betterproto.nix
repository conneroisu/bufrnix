{
  pkgs,
  lib,
  cfg,
  ...
}:
with lib; {
  # Runtime dependencies for betterproto generation
  runtimeInputs = optionals cfg.enable [
    cfg.package
    pkgs.python3
  ];

  # Protoc plugins for betterproto
  protocPlugins =
    optionals cfg.enable [
      "--python_betterproto_out=${cfg.outputPath}"
    ]
    ++ (optionals (cfg.enable && cfg.options != []) [
      "--python_betterproto_opt=${concatStringsSep " --python_betterproto_opt=" cfg.options}"
    ]);

  # Initialization hooks for betterproto
  initHooks = optionalString cfg.enable ''
    # Betterproto generation setup
    echo "Setting up betterproto (modern Python dataclasses) generation..."

    # Note: betterproto generates Python 3.6+ compatible dataclasses
    # with proper type annotations and async support
  '';

  # Code generation hooks for betterproto
  generateHooks = optionalString cfg.enable ''
    # Betterproto-specific post-processing
    echo "Post-processing betterproto dataclasses..."

    # Betterproto generates cleaner, more Pythonic code
    # No additional __init__.py files needed as betterproto handles this
    find ${cfg.outputPath} -name "*.py" -type f | while read -r file; do
      if grep -q "@dataclass" "$file" 2>/dev/null; then
        echo "Generated betterproto dataclass: $file"
      fi
    done
  '';
}
