{
  pkgs,
  config,
  lib,
  cfg ? config.languages.go,
  ...
}:

with lib;

let
  # Define output path and options
  outputPath = cfg.outputPath;
  goOptions = cfg.options;

  # Import Go-specific sub-modules
  grpcModule = import ./grpc.nix { 
    inherit pkgs lib; 
    cfg = cfg.grpc // { 
      outputPath = outputPath;
    };
  };

  connectModule = import ./connect.nix { 
    inherit pkgs lib; 
    cfg = (cfg.connect or { enable = false; }) // { 
      outputPath = outputPath;
    };
  };

  gatewayModule = import ./gateway.nix { 
    inherit pkgs lib; 
    cfg = (cfg.gateway or { enable = false; }) // { 
      outputPath = outputPath;
    };
  };

  validateModule = import ./validate.nix { 
    inherit pkgs lib; 
    cfg = (cfg.validate or { enable = false; }) // { 
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
    ]);
in {
  # Runtime dependencies for Go code generation
  runtimeInputs = [
    pkgs.protoc-gen-go
  ] ++ (combineModuleAttrs "runtimeInputs");

  # Protoc plugin configuration for Go
  protocPlugins = [
    "--go_out=${outputPath}"
    "--go_opt=${concatStringsSep " --go_opt=" goOptions}"
  ] ++ (combineModuleAttrs "protocPlugins");

  # Initialization hook for Go
  initHooks = ''
    # Create go-specific directories
    mkdir -p "${outputPath}"
    ${optionalString (cfg.packagePrefix != "") ''
      echo "Creating go package with prefix: ${cfg.packagePrefix}"
    ''}
  '' + concatStrings (catAttrs "initHooks" [
    grpcModule 
    connectModule 
    gatewayModule
    validateModule
  ]);

  # Code generation hook for Go
  generateHooks = ''
    # Go-specific code generation steps
    echo "Generating Go code..."
    mkdir -p ${outputPath}
  '' + concatStrings (catAttrs "generateHooks" [
    grpcModule 
    connectModule 
    gatewayModule
    validateModule
  ]);
}