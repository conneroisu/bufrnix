{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath or "gen/c/nanopb";
  options = cfg.options or [];

  # Build nanopb-specific options
  nanopbOptions =
    options
    ++ optionals (cfg.maxSize != 1024) [
      "max_size=${toString cfg.maxSize}"
    ]
    ++ optionals cfg.fixedLength [
      "fixed_length=true"
    ]
    ++ optionals cfg.noUnions [
      "no_unions=true"
    ]
    ++ optionals (cfg.msgidType != "") [
      "msgid_type=${cfg.msgidType}"
    ];
    
  # Build nanopb from source with proper Python module structure
  nanopbFixed = pkgs.stdenv.mkDerivation rec {
    pname = "nanopb-fixed";
    version = "0.4.9.1-bufrnix-fix2";
    
    src = pkgs.fetchFromGitHub {
      owner = "nanopb";
      repo = "nanopb";
      rev = "0.4.9.1";
      sha256 = "0dqhk6rb5mmvr45a0n78ncxb270d7qirrpidh8g00ykwl5jrki3c";
    };
    
    nativeBuildInputs = with pkgs; [
      cmake
      python312
      python312Packages.protobuf
      python312Packages.grpcio-tools
      protobuf
    ];
    
    buildInputs = with pkgs; [
      protobuf
    ];
    
    cmakeFlags = [
      "-DBUILD_STATIC_LIBS=ON" 
      "-Dnanopb_BUILD_RUNTIME=ON"
      "-Dnanopb_BUILD_GENERATOR=ON"
      "-DPYTHON_EXECUTABLE=${pkgs.python312}/bin/python3"
      "-DPROTOC_EXE=${pkgs.protobuf}/bin/protoc"
      "-DProtobuf_PROTOC_EXE=${pkgs.protobuf}/bin/protoc"
      "-DProtobuf_PROTOC_EXECUTABLE=${pkgs.protobuf}/bin/protoc"
    ];
    
    # We need to set the Python install directory at configure time
    preConfigure = ''
      # Set Python paths
      export PYTHON=${pkgs.python312}/bin/python3
      export PYTHONPATH=${pkgs.python312Packages.protobuf}/lib/python3.12/site-packages:${pkgs.python312Packages.grpcio-tools}/lib/python3.12/site-packages:$PYTHONPATH
      
      # Override the Python install directory
      cmakeFlagsArray+=("-Dnanopb_PYTHON_INSTDIR_OVERRIDE=$out/lib/python3.12/site-packages")
      
      # Create a symlink to protoc in the generator directory to fix nanopb build
      mkdir -p generator
      ln -sf ${pkgs.protobuf}/bin/protoc generator/protoc
    '';
    
    postInstall = ''
      # Fix the shebang in the scripts
      substituteInPlace $out/bin/protoc-gen-nanopb \
        --replace "#!/usr/bin/env python3" "#!${pkgs.python312}/bin/python3"
        
      substituteInPlace $out/bin/nanopb_generator \
        --replace "#!/usr/bin/env python3" "#!${pkgs.python312}/bin/python3"
        
      # The protoc-gen-nanopb script expects to import from nanopb_generator
      # But our module is at nanopb.generator.nanopb_generator
      # Create a wrapper that sets up PYTHONPATH correctly
      mv $out/bin/protoc-gen-nanopb $out/bin/.protoc-gen-nanopb-unwrapped
      
      cat > $out/bin/protoc-gen-nanopb << EOF
      #!${pkgs.bash}/bin/bash
      export PYTHONPATH=$out/lib/python3.12/site-packages:${pkgs.python312Packages.protobuf}/lib/python3.12/site-packages:${pkgs.python312Packages.grpcio-tools}/lib/python3.12/site-packages:\$PYTHONPATH
      exec ${pkgs.python312}/bin/python3 $out/bin/.protoc-gen-nanopb-unwrapped "\$@"
      EOF
      
      chmod +x $out/bin/protoc-gen-nanopb
    '';
  };
  
  # Use our custom-built nanopb if no package is specified
  # Force using our fixed version for now
  nanopbPackage = nanopbFixed;
  
in {
  runtimeInputs = optionals enabled [
    nanopbPackage
    pkgs.protobuf
    pkgs.python312Packages.protobuf
    pkgs.python312Packages.grpcio-tools
  ];

  protocPlugins =
    optionals enabled [
      "--plugin=protoc-gen-nanopb=${nanopbPackage}/bin/protoc-gen-nanopb"
      "--nanopb_out=${outputPath}"
    ];

  initHooks = optionalString enabled ''
    echo "Setting up nanopb generation with custom-built nanopb (v3-fixed)..."
    echo "Using nanopb from: ${nanopbPackage}"
    echo "Protoc plugin: ${nanopbPackage}/bin/protoc-gen-nanopb"
    mkdir -p "${outputPath}"
  '';

  generateHooks = optionalString enabled ''
    echo "Generating nanopb code..."
  '';
}
