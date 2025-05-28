{
  pkgs,
  lib,
  cfg,
  ...
}:
with lib; let
  # Define gRPC-specific options
  grpcOptions = cfg.options or [];
  outputPath = cfg.outputPath;
in {
  # Runtime dependencies for gRPC C# code generation
  runtimeInputs = [
    pkgs.grpc
  ];

  # Protoc plugin configuration for gRPC C#
  protocPlugins = optionals cfg.enable ([
    "--grpc_out=${outputPath}"
    "--plugin=protoc-gen-grpc=${pkgs.grpc}/bin/grpc_csharp_plugin"
  ] ++ (optionals (grpcOptions != []) [
    "--grpc_opt=${concatStringsSep "," grpcOptions}"
  ]));

  # Initialization hook for gRPC C#
  initHooks = optionalString cfg.enable ''
    # gRPC C# specific initialization
    echo "Initializing gRPC C# code generation..."
  '';

  # Code generation hook for gRPC C#
  generateHooks = optionalString cfg.enable ''
    # gRPC C# specific code generation
    echo "Generated gRPC C# service code"
    
    # Generate client factory if enabled
    ${optionalString cfg.generateClientFactory ''
      echo "Generating gRPC client factory..."
      # This would generate a factory class for creating gRPC clients
      # Implementation depends on specific requirements
    ''}
    
    # Generate server base implementations if enabled
    ${optionalString cfg.generateServerBase ''
      echo "Generating gRPC server base implementations..."
      # This would generate base server implementations
      # Implementation depends on specific requirements
    ''}
  '';
}