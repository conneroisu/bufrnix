{
  pkgs,
  config,
  lib,
  cfg ? config.languages.cpp,
  ...
}:
with lib; let
  # Define output path and options
  outputPath = cfg.outputPath;
  cppOptions = cfg.options;

  # Select protobuf version based on configuration
  protobufPkg =
    if cfg.protobufVersion == "latest" || cfg.protobufVersion == "5.29"
    then pkgs.protobuf
    else if cfg.protobufVersion == "4.25"
    then pkgs.protobuf_25 or pkgs.protobuf
    else if cfg.protobufVersion == "3.27"
    then pkgs.protobuf3_27 or pkgs.protobuf
    else if cfg.protobufVersion == "3.25"
    then pkgs.protobuf3_25 or pkgs.protobuf
    else if cfg.protobufVersion == "3.21"
    then pkgs.protobuf3_21 or pkgs.protobuf
    else pkgs.protobuf;

  # Build gRPC with matching protobuf version if needed
  grpcPkg =
    if cfg.grpc.enable or false
    then pkgs.grpc.override {protobuf = protobufPkg;}
    else null;

  # Import C++ sub-modules
  grpcModule = import ./grpc.nix {
    inherit pkgs lib protobufPkg;
    cfg =
      (cfg.grpc or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  cmakeModule = import ./cmake.nix {
    inherit pkgs lib;
    cfg =
      cfg
      // {
        protobufPkg = protobufPkg;
        grpcPkg = grpcPkg;
      };
  };

  # Combine all sub-modules
  combineModuleAttrs = attr:
    concatLists (catAttrs attr [
      grpcModule
    ]);
in {
  # Runtime dependencies for C++ code generation
  runtimeInputs =
    [
      protobufPkg
      cfg.package or protobufPkg
    ]
    ++ (combineModuleAttrs "runtimeInputs")
    ++ optional (cfg.grpc.enable or false) grpcPkg
    ++ optional (cfg.cmakeIntegration) pkgs.cmake;

  # Protoc plugin configuration for C++
  protocPlugins =
    [
      "--cpp_out=${outputPath}"
    ]
    ++ (combineModuleAttrs "protocPlugins");

  # Initialization hook for C++
  initHooks =
    ''
      # Create C++-specific directories
      mkdir -p "${outputPath}"
      ${optionalString (cfg.includePaths != []) ''
        echo "Using additional include paths: ${concatStringsSep ", " cfg.includePaths}"
      ''}
      ${optionalString cfg.arenaAllocation ''
        echo "Arena allocation optimization enabled"
      ''}
    ''
    + concatStrings (catAttrs "initHooks" [
      grpcModule
      cmakeModule
    ]);

  # Code generation hook for C++
  generateHooks =
    ''
      # C++-specific code generation steps
      echo "Generating C++ code with protobuf ${cfg.protobufVersion}..."
      echo "Using ${cfg.standard} standard with ${cfg.optimizeFor} optimization"
      mkdir -p ${outputPath}
    ''
    + concatStrings (catAttrs "generateHooks" [
      grpcModule
      cmakeModule
    ]);
}
