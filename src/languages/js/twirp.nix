{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib;
# Only activate if Twirp is enabled
  (
    if cfg.enable or false
    then {
      # Runtime dependencies for Twirp
      runtimeInputs = [
        # Custom or community package for Twirp JS
        pkgs.nodejs
      ];

      # Protoc plugin configuration (assuming a hypothetical Twirp JS plugin)
      protocPlugins = [
        # Note: This is a placeholder. As of now, there's no official Twirp JS plugin
        # You would need to specify the correct plugin when available
        "--twirp_js_out=${cfg.outputPath}"
      ];

      # Initialize hook
      initHooks = ''
        echo "Initializing JavaScript Twirp..."
      '';

      # Generate hook
      generateHooks = ''
        echo "Generating JavaScript Twirp code..."
      '';
    }
    else {}
  )
