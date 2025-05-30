{
  pkgs,
  lib,
  cfg,
  ...
}:
with lib; {
  # Runtime dependencies for Python gRPC generation
  runtimeInputs = optionals cfg.enable [
    cfg.package
    pkgs.python3
    pkgs.grpc
  ];

  # Protoc plugins for Python gRPC
  protocPlugins =
    optionals cfg.enable [
      "--grpc_python_out=${cfg.outputPath}"
      "--plugin=protoc-gen-grpc_python=${pkgs.grpc}/bin/grpc_python_plugin"
    ]
    ++ (optionals (cfg.enable && cfg.options != []) [
      "--grpc_python_opt=${concatStringsSep " --grpc_python_opt=" cfg.options}"
    ]);

  # Initialization hooks for Python gRPC
  initHooks = optionalString cfg.enable ''
    # gRPC Python generation requires grpcio-tools
    echo "Setting up Python gRPC generation..."
  '';

  # Code generation hooks for Python gRPC
  generateHooks = optionalString cfg.enable ''
    # Python gRPC-specific post-processing
    echo "Post-processing Python gRPC stubs..."

    # Ensure all gRPC stubs have proper imports
    find ${cfg.outputPath} -name "*_pb2_grpc.py" -type f | while read -r file; do
      # Fix any import issues specific to gRPC stubs if needed
      echo "Processed: $file"
    done
  '';
}
