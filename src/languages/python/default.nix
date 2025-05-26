{
  pkgs,
  config,
  lib,
  cfg ? config.languages.python,
  ...
}:
with lib; let
  # Define output path and options
  outputPath = cfg.outputPath;
  pythonOptions = cfg.options;

  # Import Python-specific sub-modules
  grpcModule = import ./grpc.nix {
    inherit pkgs lib;
    cfg =
      (cfg.grpc or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  pyiModule = import ./pyi.nix {
    inherit pkgs lib;
    cfg =
      (cfg.pyi or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  betterprotoModule = import ./betterproto.nix {
    inherit pkgs lib;
    cfg =
      (cfg.betterproto or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  mypyModule = import ./mypy.nix {
    inherit pkgs lib;
    cfg =
      (cfg.mypy or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  # Combine all sub-modules
  combineModuleAttrs = attr:
    concatLists (catAttrs attr [
      grpcModule
      pyiModule
      betterprotoModule
      mypyModule
    ]);
in {
  # Runtime dependencies for Python code generation
  runtimeInputs =
    [
      cfg.package
      pkgs.python3
    ]
    ++ (combineModuleAttrs "runtimeInputs");

  protocPlugins =
    [
      "--python_out=${outputPath}"
    ]
    ++ (optionals (pythonOptions != []) [
      "--python_opt=${concatStringsSep " --python_opt=" pythonOptions}"
    ])
    ++ (combineModuleAttrs "protocPlugins");

  # Initialization hook for Python
  initHooks =
    ''
      # Create python-specific directories
      mkdir -p "${outputPath}"

      # Create __init__.py files for proper Python packages
      find "${outputPath}" -type d -exec touch {}/__init__.py \;
    ''
    + concatStrings (catAttrs "initHooks" [
      grpcModule
      pyiModule
      betterprotoModule
      mypyModule
    ]);

  # Code generation hook for Python
  generateHooks =
    ''
      # Python-specific code generation steps
      echo "Generating Python code..."
      mkdir -p ${outputPath}

      # Create __init__.py files for all generated packages
      echo "Creating Python package structure..."
      find ${outputPath} -type d -exec touch {}/__init__.py \;
    ''
    + concatStrings (catAttrs "generateHooks" [
      grpcModule
      pyiModule
      betterprotoModule
      mypyModule
    ]);
}
