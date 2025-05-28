# Simple test for Kotlin language support
{ pkgs ? import <nixpkgs> {} }:

let
  # Import bufrnix
  bufrnixFlake = builtins.getFlake (toString ./.);
  mkBufrnix = bufrnixFlake.lib.${pkgs.system}.mkBufrnix;
  
  # Create a simple test proto file
  testProto = pkgs.writeTextDir "test.proto" ''
    syntax = "proto3";
    package test;
    option java_package = "com.test";
    option java_multiple_files = true;
    
    message TestMessage {
      string id = 1;
      string name = 2;
    }
  '';
  
  # Test Kotlin generation
  testDerivation = mkBufrnix {
    root = testProto;
    languages = {
      kotlin = {
        enable = true;
      };
    };
  };
  
in testDerivation