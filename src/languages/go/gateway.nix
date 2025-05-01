# https://github.com/grpc-ecosystem/grpc-gateway
{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.generators.go.gateway;
in {
  options.generators.go.gateway = {
    enable = mkEnableOption "protoc-gen-go-gateway";
    package = mkOption {
      type = types.package;
      default = pkgs.grpc-gateway;
      description = ''
        The package that provides the `protoc-gen-go-gateway` binary, and
        includes it in the generation step.


        URL: https://github.com/grpc-ecosystem/grpc-gateway
      '';
    };
  };

  config = mkIf cfg.enable {
    buildInputs = [
      cfg.package
    ];
  };
}
