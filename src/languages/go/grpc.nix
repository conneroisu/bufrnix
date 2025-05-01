{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.generators.go.grpc;
in {
  options.generators.go.grpc = {
    enable = mkEnableOption "protoc-gen-go-grpc";
    package = mkOption {
      type = types.package;
      default = pkgs.protoc-gen-go-grpc;
      description = ''
        The package that provides the `protoc-gen-go-grpc` binary, and
        includes it in the generation step.

        Configuratble Behavior:
          - Verbosity: (GRPC_GO_LOG_VERBOSITY_LEVEL) - The verbosity level for the gRPC
          - Output: (--go_out) - The output directory for the generated files
          - Plugin Out: (--go-grpc_out) - The output directory for the generated files
          - Plugin: (--go-grpc_opt) - The options to pass to the plugin
          - Opt: (--go_opt) - The output directory for the generated files

        URL: https://github.com/grpc/grpc-go
      '';
    };
  };

  config = mkIf cfg.enable {
    buildInputs = [
      cfg.package
    ];
  };
}
