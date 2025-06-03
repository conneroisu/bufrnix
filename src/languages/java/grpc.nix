{pkgs, lib, cfg, ...}:
with lib;
if cfg.enable then {
  # Runtime dependencies
  runtimeInputs = [ cfg.package ];
  
  # Protoc plugins configuration
  protocPlugins = [
    "--grpc-java_out=${cfg.outputPath}"
    "--plugin=protoc-gen-grpc-java=${cfg.package}/bin/protoc-gen-grpc-java"
  ] ++ (optionals (cfg.options != []) ["--grpc-java_opt=${concatStringsSep " --grpc-java_opt=" cfg.options}"]);
  
  # Additional initialization steps
  initHooks = ''
    # Ensure gRPC output directory exists
    mkdir -p "${cfg.outputPath}"
  '';
} else {
  runtimeInputs = [];
  protocPlugins = [];
  initHooks = "";
}