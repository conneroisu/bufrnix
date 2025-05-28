{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib;
  if cfg.enable or false
  then let
    outputPath = cfg.outputPath or "gen/js";
    connectOptions = cfg.options or [];
    # Connect-ES functionality is now integrated into protoc-gen-es v2
    # We use protoc-gen-es with plugin=connect_target=ts option
  in {
    # Runtime dependencies for Connect-ES code generation
    runtimeInputs = [
      pkgs.protoc-gen-es # Connect support is built into v2
    ];

    # Protoc plugin configuration for Connect-ES
    # Connect is generated alongside messages with protoc-gen-es v2
    protocPlugins = [
      # Connect generation is handled by ES module with plugin option
      (optionalString (connectOptions != []) "--es_opt=plugin=connect_target=ts,${concatStringsSep "," connectOptions}")
    ];

    # Initialization hook for Connect-ES
    initHooks = ''
      # Connect code is generated alongside protobuf-es messages
      echo "Connect-ES service generation enabled via protoc-gen-es v2..."
    '';

    # Code generation hook for Connect-ES
    generateHooks = ''
      # Connect-ES specific generation steps
      echo "Connect-ES services generated alongside Protobuf-ES messages"

      # Generate package.json if needed
      ${optionalString (cfg.generatePackageJson or false) ''
              if [ ! -f ${outputPath}/package.json ]; then
                cat > ${outputPath}/package.json <<EOF
        {
          "name": "${cfg.packageName or "generated-connect-es"}",
          "version": "1.0.0",
          "type": "module",
          "dependencies": {
            "@connectrpc/connect": "^1.4.0",
            "@connectrpc/connect-web": "^1.4.0",
            "@bufbuild/protobuf": "^2.0.0"
          }
        }
        EOF
              else
                echo "package.json already exists, adding Connect dependencies..."
              fi
      ''}
    '';
  }
  else {}
