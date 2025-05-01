{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.generators.go.validate;
in {
  options.generators.go.validate = {
    enable = mkEnableOption "protoc-gen-validate";
    package = mkOption {
      type = types.package;
      default = pkgs.protoc-gen-validate;
      description = ''
        The package that provides the `protoc-gen-validate` binary, and
        includes it in the generation step.

        URL: https://github.com/bufbuild/protovalidate-go
      '';
    };
    documentation = "https://github.com/bufbuild/protovalidate-go";
  };

  config = mkIf cfg.enable {
    buildInputs = [
      cfg.package
    ];
  };
}
