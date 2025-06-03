{
  pkgs,
  lib,
  cfg,
  ...
}:
with lib; let
  outputPath = cfg.outputPath;
  scalapbPackage = cfg.scalapbPackage;
  grpcOptions = cfg.options or [];
in
  mkIf cfg.enable {
    # Runtime dependencies specific to Scala gRPC
    runtimeInputs = [];
    
    # Protoc plugin configuration for Scala gRPC
    protocPlugins = 
      (optionals (grpcOptions != []) [
        "--scala_opt=${concatStringsSep "," (["grpc"] ++ grpcOptions)}"
      ]) ++ (optionals (grpcOptions == []) [
        "--scala_opt=grpc"
      ]);
    
    # Initialization hooks for Scala gRPC
    initHooks = ''
      echo "Configuring Scala gRPC support..."
    '';
    
    # Code generation hooks for Scala gRPC
    generateHooks = ''
      echo "Generated Scala code with gRPC support"
    '';
  }