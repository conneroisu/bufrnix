{
  pkgs,
  lib,
  cfg,
  ...
}:
with lib; let
  # Define gRPC-specific options
  grpcOptions = cfg.options or [];
  javaOutputPath = cfg.javaOutputPath;
  kotlinOutputPath = cfg.kotlinOutputPath;

  # Create wrapper script for grpc-kotlin plugin
  grpcKotlinPlugin = if cfg.enable then
    pkgs.writeShellScriptBin "protoc-gen-grpckt" ''
      #!/usr/bin/env sh
      # Wrapper script for gRPC Kotlin plugin JAR
      if [ -n "$GRPC_KOTLIN_JAR" ]; then
        ${cfg.jdk}/bin/java -jar "$GRPC_KOTLIN_JAR" "$@"
      else
        ${cfg.jdk}/bin/java -jar ${if cfg.grpcKotlinJar != null then cfg.grpcKotlinJar else ".bufrnix-cache/protoc-gen-grpc-kotlin.jar"} "$@"
      fi
    ''
  else null;
in {
  # Runtime dependencies for gRPC Kotlin code generation
  runtimeInputs = optionals cfg.enable [
    pkgs.grpc # For grpc_java_plugin
    grpcKotlinPlugin
  ];

  # Protoc plugin configuration for gRPC Kotlin
  protocPlugins = optionals cfg.enable ([
      # Generate Java gRPC stubs (required for Kotlin)
      "--grpc_out=${javaOutputPath}"
      "--plugin=protoc-gen-grpc=${pkgs.grpc}/bin/grpc_java_plugin"

      # Generate Kotlin gRPC stubs
      "--grpckt_out=${kotlinOutputPath}"
      "--plugin=protoc-gen-grpckt=${grpcKotlinPlugin}/bin/protoc-gen-grpckt"
    ]
    ++ (optionals (grpcOptions != []) [
      "--grpckt_opt=${concatStringsSep "," grpcOptions}"
    ]));

  # Initialization hook for gRPC Kotlin
  initHooks = optionalString cfg.enable ''
    # gRPC Kotlin specific initialization
    echo "Initializing gRPC Kotlin code generation..."

    # Download gRPC Kotlin plugin JAR if not provided
    ${optionalString (cfg.grpcKotlinJar == null) ''
      echo "Downloading gRPC Kotlin plugin JAR..."
      mkdir -p .bufrnix-cache
      ${pkgs.curl}/bin/curl -L -o .bufrnix-cache/protoc-gen-grpc-kotlin.jar \
        "https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-kotlin/${cfg.grpcKotlinVersion}/protoc-gen-grpc-kotlin-${cfg.grpcKotlinVersion}-jdk8.jar"
      export GRPC_KOTLIN_JAR=".bufrnix-cache/protoc-gen-grpc-kotlin.jar"
    ''}
  '';

  # Code generation hook for gRPC Kotlin
  generateHooks = optionalString cfg.enable ''
    # gRPC Kotlin specific code generation
    echo "Generated gRPC Kotlin service code"

    # Create service implementations if enabled
    ${optionalString cfg.generateServiceImpl ''
      echo "Generating gRPC service implementations..."
      # This would generate base service implementations
      # Implementation depends on specific requirements
    ''}
  '';
}
