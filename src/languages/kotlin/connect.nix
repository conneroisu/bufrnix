{
  pkgs,
  lib,
  cfg,
  ...
}:
with lib; let
  # Define Connect-specific options
  connectOptions = cfg.options or [];
  javaOutputPath = cfg.javaOutputPath;
  kotlinOutputPath = cfg.kotlinOutputPath;

  # Create wrapper script for Connect Kotlin plugin
  connectKotlinPlugin = if cfg.enable then
    pkgs.writeShellScriptBin "protoc-gen-connect-kotlin" ''
      #!/usr/bin/env sh
      # Wrapper script for Connect Kotlin plugin
      if [ -n "$CONNECT_KOTLIN_JAR" ]; then
        ${cfg.jdk}/bin/java -jar "$CONNECT_KOTLIN_JAR" "$@"
      else
        ${cfg.jdk}/bin/java -jar ${if cfg.connectKotlinJar != null then cfg.connectKotlinJar else ".bufrnix-cache/protoc-gen-connect-kotlin.jar"} "$@"
      fi
    ''
  else null;
in {
  # Runtime dependencies for Connect Kotlin code generation
  runtimeInputs = optionals cfg.enable [
    connectKotlinPlugin
  ];

  # Protoc plugin configuration for Connect Kotlin
  protocPlugins = optionals cfg.enable ([
      # Generate Connect Kotlin code
      "--connect-kotlin_out=${kotlinOutputPath}"
      "--plugin=protoc-gen-connect-kotlin=${connectKotlinPlugin}/bin/protoc-gen-connect-kotlin"
    ]
    ++ (optionals (connectOptions != []) [
      "--connect-kotlin_opt=${concatStringsSep "," connectOptions}"
    ]));

  # Initialization hook for Connect Kotlin
  initHooks = optionalString cfg.enable ''
    # Connect Kotlin specific initialization
    echo "Initializing Connect RPC Kotlin code generation..."

    # Download Connect Kotlin plugin JAR if not provided
    ${optionalString (cfg.connectKotlinJar == null) ''
      echo "Downloading Connect Kotlin plugin JAR..."
      mkdir -p .bufrnix-cache
      ${pkgs.curl}/bin/curl -L -o .bufrnix-cache/protoc-gen-connect-kotlin.jar \
        "https://repo1.maven.org/maven2/com/connectrpc/protoc-gen-connect-kotlin/${cfg.connectVersion}/protoc-gen-connect-kotlin-${cfg.connectVersion}.jar"
      export CONNECT_KOTLIN_JAR=".bufrnix-cache/protoc-gen-connect-kotlin.jar"
    ''}
  '';

  # Code generation hook for Connect Kotlin
  generateHooks = optionalString cfg.enable ''
    # Connect Kotlin specific code generation
    echo "Generated Connect RPC Kotlin code"

    # Generate client configuration if enabled
    ${optionalString cfg.generateClientConfig ''
      echo "Generating Connect client configuration..."
      cat > "${kotlinOutputPath}/ConnectConfig.kt" <<EOF
      package ${cfg.packageName}

      import com.connectrpc.ConnectInterceptor
      import com.connectrpc.ProtocolClientConfig
      import com.connectrpc.extensions.GoogleJavaProtobufStrategy
      import com.connectrpc.impl.ProtocolClient
      import com.connectrpc.okhttp.ConnectOkHttpClient
      import okhttp3.OkHttpClient

      object ConnectConfig {
          fun createClient(
              host: String,
              interceptors: List<ConnectInterceptor> = emptyList()
          ): ProtocolClient {
              val okHttpClient = OkHttpClient.Builder().build()
              return ConnectOkHttpClient(
                  httpClient = okHttpClient,
                  config = ProtocolClientConfig(
                      host = host,
                      serializationStrategy = GoogleJavaProtobufStrategy(),
                      interceptors = interceptors
                  )
              )
          }
      }
      EOF
    ''}
  '';
}
