{
  pkgs,
  config,
  lib,
  cfg ? config.languages.go,
  ...
}:
with lib; let
  # Define output path and options
  outputPath = cfg.outputPath;
  goOptions = cfg.options;

  # Import Go-specific sub-modules
  grpcModule = import ./grpc.nix {
    inherit pkgs lib;
    cfg =
      cfg.grpc
      // {
        outputPath = outputPath;
      };
  };

  connectModule = import ./connect.nix {
    inherit pkgs lib;
    cfg =
      (cfg.connect or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  gatewayModule = import ./gateway.nix {
    inherit pkgs lib;
    cfg =
      (cfg.gateway or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  validateModule = import ./validate.nix {
    inherit pkgs lib;
    cfg =
      (cfg.validate or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  protovalidateModule = import ./protovalidate.nix {
    inherit pkgs lib;
    cfg =
      (cfg.protovalidate or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  openapiv2Module = import ./openapiv2.nix {
    inherit pkgs lib;
    cfg =
      (cfg.openapiv2 or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  vtprotobufModule = import ./vtprotobuf.nix {
    inherit pkgs lib;
    cfg =
      (cfg.vtprotobuf or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  jsonModule = import ./json.nix {
    inherit pkgs lib;
    cfg =
      (cfg.json or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  federationModule = import ./federation.nix {
    inherit pkgs lib;
    cfg =
      (cfg.federation or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  structTransformerModule = import ./struct-transformer.nix {
    inherit pkgs lib;
    cfg =
      (cfg.structTransformer or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  # Combine all sub-modules
  combineModuleAttrs = attr:
    concatLists (catAttrs attr [
      grpcModule
      connectModule
      gatewayModule
      validateModule
      protovalidateModule
      openapiv2Module
      vtprotobufModule
      jsonModule
      federationModule
      structTransformerModule
    ]);
in {
  # Runtime dependencies for Go code generation
  runtimeInputs =
    [
      cfg.package
    ]
    ++ (combineModuleAttrs "runtimeInputs");

  # Protoc plugin configuration for Go
  protocPlugins =
    [
      "--go_out=${outputPath}"
      "--go_opt=${concatStringsSep " --go_opt=" goOptions}"
    ]
    ++ (combineModuleAttrs "protocPlugins");

  # Initialization hook for Go
  initHooks =
    ''
      # Create go-specific directories
      mkdir -p "${outputPath}"
      ${optionalString (cfg.packagePrefix != "") ''
        echo "Creating go package with prefix: ${cfg.packagePrefix}"
      ''}
    ''
    + concatStrings (catAttrs "initHooks" [
      grpcModule
      connectModule
      gatewayModule
      validateModule
      protovalidateModule
      openapiv2Module
      vtprotobufModule
      jsonModule
      federationModule
      structTransformerModule
    ]);

  # Code generation hook for Go
  generateHooks =
    ''
      # Go-specific code generation steps
      echo "Generating Go code..."
      mkdir -p ${outputPath}
    ''
    + concatStrings (catAttrs "generateHooks" [
      grpcModule
      connectModule
      gatewayModule
      validateModule
      protovalidateModule
      openapiv2Module
      vtprotobufModule
      jsonModule
      federationModule
      structTransformerModule
    ]);
}
