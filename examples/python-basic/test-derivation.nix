# Test derivation to verify code generation
{pkgs ? import <nixpkgs> {}}: let
  # Import bufrnix flake
  flake = builtins.getFlake "path:${../..}";
  bufrnix = flake.outputs;

  bufrnixConfig = bufrnix.lib.mkBufrnixPackage {
    inherit pkgs;
    config = {
      root = "./proto";
      languages.python = {
        enable = true;
        outputPath = "proto/gen/python";
      };
    };
  };
in
  pkgs.stdenv.mkDerivation {
    name = "python-basic-test";
    src = ./.;

    buildInputs = with pkgs; [
      python3
      python3Packages.protobuf
      protobuf
      buf
    ];

    buildPhase = ''
      # Copy source
      cp -r . $out
      cd $out

      # Generate code
      ${bufrnixConfig.init}
      ${bufrnixConfig.generate}

      # List generated files
      echo "=== Generated files ==="
      find proto/gen -type f -name "*.py" | sort

      # Run test
      echo "=== Running test ==="
      ${pkgs.python3}/bin/python test.py
    '';

    installPhase = "true";
  }
