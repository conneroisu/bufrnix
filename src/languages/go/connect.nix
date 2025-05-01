# https://github.com/grpc-ecosystem/grpc-
{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.generators.go.connect;
in {
  options.generators.go.pluginrpc = {
    enable = mkEnableOption "protoc-gen-go-connect";
    package = mkOption {
      type = types.package;
      default = pkgs.protoc-gen-connect-go;
      description = ''
        The package that provides the `protoc-gen-connect-go` binary, and
        includes it in the generation step.

        URL: https://github.com/connectrpc/connect-go
      '';
    };
  };

  config = mkIf cfg.enable {
    buildInputs = [
      cfg.package
    ];
  };
}
