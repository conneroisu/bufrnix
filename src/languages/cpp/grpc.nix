{
  pkgs,
  lib,
  protobufPkg,
  cfg ? {},
  ...
}:
with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "gen/cpp";
  options = cfg.options or ["paths=source_relative"];

  # Use protobuf-matched gRPC
  grpcPkg = pkgs.grpc.override {protobuf = protobufPkg;};
in {
  # Runtime dependencies for gRPC C++
  runtimeInputs = optionals enabled [
    cfg.package or grpcPkg
    grpcPkg.dev or grpcPkg
  ];

  # Protoc plugin configuration for gRPC C++
  protocPlugins = optionals enabled [
    "--grpc_out=${outputPath}"
    "--grpc_opt=${concatStringsSep " --grpc_opt=" options}"
    "--plugin=protoc-gen-grpc=${grpcPkg}/bin/grpc_cpp_plugin"
  ];

  # Initialization hooks for gRPC C++
  initHooks = optionalString enabled ''
    echo "Setting up C++ gRPC generation..."
    echo "gRPC version: ${grpcPkg.version or "unknown"}"
    mkdir -p "${outputPath}/grpc"
  '';

  # Generation hooks for gRPC C++
  generateHooks = optionalString enabled ''
    echo "Configuring C++ gRPC generation..."
    echo "Generated gRPC services will include client and server stubs"
  '';
}

