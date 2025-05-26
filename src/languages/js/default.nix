{
  pkgs,
  config,
  lib,
  cfg ? config.languages.js,
  ...
}:
with lib; let
  # Define output path and options
  outputPath = cfg.outputPath;
  jsOptions = cfg.options;

  # Import JS-specific sub-modules
  grpcWebModule = import ./grpc-web.nix {
    inherit pkgs lib;
    cfg =
      cfg.grpcWeb
      // {
        outputPath = outputPath;
      };
  };

  twirpModule = import ./twirp.nix {
    inherit pkgs lib;
    cfg =
      cfg.twirp
      // {
        outputPath = outputPath;
      };
  };

  # Combine all sub-modules
  combineModuleAttrs = attr:
    concatLists (catAttrs attr [
      grpcWebModule
      twirpModule
    ]);
in {
  # Runtime dependencies for JS code generation
  runtimeInputs =
    [
      # Base JS dependencies
      pkgs.protobuf
      pkgs.nodePackages.typescript
    ]
    ++ (optional (cfg.package != null) cfg.package)
    ++ (optionals cfg.es.enable [cfg.es.package])
    ++ (optionals cfg.connect.enable [cfg.connect.package])
    ++ (combineModuleAttrs "runtimeInputs");

  # Protoc plugin configuration for JS
  protocPlugins =
    # Only add JS output if package is available
    (optional (cfg.package != null)
      "--js_out=import_style=commonjs,binary:${outputPath}")
    ++ [
      # ECMAScript output for modern JavaScript if enabled
      (optionalString cfg.es.enable
        "--plugin=protoc-gen-es=${cfg.es.package}/bin/protoc-gen-es --es_out=${outputPath}")
    ]
    ++ (combineModuleAttrs "protocPlugins");

  # Initialization hook for JS
  initHooks =
    ''
      # Create js-specific directories
      mkdir -p "${outputPath}"
      ${optionalString (cfg.packageName != "") ''
        echo "Creating JS package: ${cfg.packageName}"
      ''}
    ''
    + concatStrings (catAttrs "initHooks" [
      grpcWebModule
      twirpModule
    ]);

  # Code generation hook for JS
  generateHooks =
    ''
      # JS-specific code generation steps
      echo "Generating JavaScript code..."
      mkdir -p ${outputPath}
      ${optionalString (cfg.package == null && pkgs.stdenv.isDarwin) ''
        echo "Note: protoc-gen-js is not available on macOS due to build issues."
        echo "Using ES modules (protoc-gen-es) or other alternatives instead."
      ''}
    ''
    + concatStrings (catAttrs "generateHooks" [
      grpcWebModule
      twirpModule
    ]);
}
