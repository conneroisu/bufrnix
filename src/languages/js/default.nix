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
      pkgs.protoc-gen-js
      pkgs.protoc-gen-grpc-web
      pkgs.protoc-gen-es
    ]
    ++ (combineModuleAttrs "runtimeInputs");

  # Protoc plugin configuration for JS
  protocPlugins =
    [
      # Use JavaScript output with CommonJS import style (standard for Node.js)
      "--js_out=import_style=commonjs,binary:${outputPath}"

      # ECMAScript output for modern JavaScript if enabled
      (optionalString cfg.es.enable
        "--plugin=protoc-gen-es=${pkgs.protoc-gen-es}/bin/protoc-gen-es --es_out=${outputPath}")
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
    ''
    + concatStrings (catAttrs "generateHooks" [
      grpcWebModule
      twirpModule
    ]);
}
