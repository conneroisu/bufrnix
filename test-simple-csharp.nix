# Simple test for C# language support
{pkgs ? import <nixpkgs> {}}: let
  # Import bufrnix
  bufrnixFlake = builtins.getFlake (toString ./.);
  mkBufrnix = bufrnixFlake.lib.${pkgs.system}.mkBufrnix;

  # Create a simple test proto file
  testProto = pkgs.writeTextDir "test.proto" ''
    syntax = "proto3";
    package test;
    option csharp_namespace = "TestNamespace";

    message TestMessage {
      string id = 1;
      string name = 2;
    }
  '';

  # Test C# generation
  testDerivation = mkBufrnix {
    root = testProto;
    languages = {
      csharp = {
        enable = true;
        namespace = "TestNamespace";
      };
    };
  };
in
  testDerivation
