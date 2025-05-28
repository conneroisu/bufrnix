# Simple test for C++ language module
{pkgs ? import <nixpkgs> {}}: let
  lib = pkgs.lib;

  # Test configuration
  testConfig = {
    languages = {
      cpp = {
        enable = true;
        outputPath = "gen/cpp";
        protobufVersion = "latest";
        standard = "c++20";
        optimizeFor = "SPEED";
        runtime = "full";
        cmakeIntegration = true;
        pkgConfigIntegration = true;
        arenaAllocation = false;
        includePaths = [];
        options = ["paths=source_relative"];
        grpc = {
          enable = false;
        };
      };
    };
  };

  # Load the C++ module directly
  cppModule = import ./src/languages/cpp {
    inherit pkgs lib;
    config = testConfig;
    cfg = testConfig.languages.cpp;
  };
in {
  # Output module attributes for inspection
  inherit cppModule;

  # Test results
  hasRuntimeInputs = builtins.length (cppModule.runtimeInputs or []) > 0;
  hasProtocPlugins = builtins.length (cppModule.protocPlugins or []) > 0;
  runtimeInputs = cppModule.runtimeInputs or [];
  protocPlugins = cppModule.protocPlugins or [];
  initHooks = cppModule.initHooks or "";
  generateHooks = cppModule.generateHooks or "";
}
