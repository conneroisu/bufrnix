{
  description = "Basic C++ Protobuf example using Bufrnix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "path:../..";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    bufrnix,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        # Generate C++ protobuf files
        generated = bufrnix.lib.mkBufrnixPackage {
          inherit (pkgs) lib;
          inherit pkgs;
          config = {
            root = ".";
            protoc = {
              includeDirectories = ["proto"];
            };

            languages.cpp = {
              enable = true;
              protobufVersion = "latest";
              standard = "c++20";
              optimizeFor = "SPEED";
              cmakeIntegration = true;
              outputPath = "proto/gen/cpp";
            };
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            cmake
            ninja
            gcc
            protobuf
            abseil-cpp
            pkg-config
            generated
          ] ++ lib.optionals pkgs.stdenv.isLinux [
            gdb
            valgrind
          ];

          shellHook = ''
            echo "C++ Protobuf Development Shell"
            echo "Generated files available at: proto/gen/cpp/"
            echo ""
            echo "To build:"
            echo "  cmake -B build -G Ninja"
            echo "  cmake --build build"
            echo ""
            echo "To run:"
            echo "  ./build/cpp-basic-example"
          '';
        };

        packages = {
          default = generated;
          generated = generated;
        };
      }
    );
}

