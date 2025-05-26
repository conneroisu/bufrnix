{
  pkgs,
  lib,
  cfg,
  ...
}:
with lib; {
  # Runtime dependencies for mypy stub generation
  runtimeInputs = optionals cfg.enable [
    cfg.package
    pkgs.python3
  ];

  # Protoc plugins for mypy stubs
  protocPlugins =
    optionals cfg.enable [
      "--mypy_out=${cfg.outputPath}"
    ]
    ++ (optionals (cfg.enable && cfg.options != []) [
      "--mypy_opt=${concatStringsSep " --mypy_opt=" cfg.options}"
    ]);

  # Initialization hooks for mypy
  initHooks = optionalString cfg.enable ''
    # Mypy stub generation setup
    echo "Setting up mypy stub generation..."

    # Mypy stubs provide better type checking support
    # for generated protobuf code
  '';

  # Code generation hooks for mypy
  generateHooks = optionalString cfg.enable ''
    # Mypy-specific post-processing
    echo "Post-processing mypy stubs..."

    # Find all generated mypy stub files
    find ${cfg.outputPath} -name "*_pb2.pyi" -o -name "*_pb2_grpc.pyi" -type f | while read -r file; do
      echo "Generated mypy stub: $file"
    done

    # Create py.typed marker for PEP 561 compliance
    touch ${cfg.outputPath}/py.typed
    echo "Created py.typed marker for type checking support"
  '';
}
