{ pkgs, lib, config, cfg, ... }:

with lib;

let
  grpcCfg = cfg.grpc;
  javaOutputPath = cfg.outputPath or "gen/java";
  
  # Build the gRPC-specific protoc arguments
  grpcArgs = concatStringsSep ":" grpcCfg.options;
  
  grpcPlugin = "--grpc-java_out=${javaOutputPath}";
  fullGrpcPlugin = if grpcArgs != "" then "${grpcPlugin}:${grpcArgs}" else grpcPlugin;
in
if grpcCfg.enable then {
  # Runtime dependencies
  runtimeInputs = [ grpcCfg.package cfg.jdk ];
  
  # Protoc plugins configuration
  protocPlugins = [
    {
      name = "grpc-java";
      plugin = "${grpcCfg.package}/bin/protoc-gen-grpc-java";
      flags = [ "--plugin=protoc-gen-grpc-java=${grpcCfg.package}/bin/protoc-gen-grpc-java" fullGrpcPlugin ];
    }
  ];
  
  # Additional build steps
  postBuild = ''
    # Ensure output directory exists
    mkdir -p ${javaOutputPath}
  '';
} else {}