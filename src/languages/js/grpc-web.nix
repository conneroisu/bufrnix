{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib;
# Only activate if gRPC-Web is enabled
  (
    if cfg.enable or false
    then {
      # Runtime dependencies for gRPC-Web
      runtimeInputs = [
        cfg.package or pkgs.protoc-gen-grpc-web
      ];

      # Protoc plugin configuration
      protocPlugins = [
        "--grpc-web_out=import_style=${cfg.importStyle or "commonjs"},mode=${cfg.mode or "grpcweb"}:${cfg.outputPath}"
      ];

      # Initialize hook
      initHooks = ''
        echo "Initializing JavaScript gRPC-Web..."
      '';

      # Generate hook
      generateHooks = ''
        echo "Generating JavaScript gRPC-Web code..."
      '';
    }
    else {}
  )
