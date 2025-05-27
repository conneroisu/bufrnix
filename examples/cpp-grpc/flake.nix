{
  description = "C++ gRPC service example using Bufrnix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "github:conneroisu/bufrnix";
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

        # Generate C++ protobuf and gRPC files
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
              arenaAllocation = true;

              # Enable gRPC
              grpc = {
                enable = true;
                generateMockCode = true;
                options = [
                  "paths=source_relative"
                ];
              };

              options = [
                "paths=source_relative"
              ];
            };
          };
        };

        # Build server
        server = pkgs.stdenv.mkDerivation {
          pname = "grpc-server";
          version = "1.0.0";
          src = ./.;

          nativeBuildInputs = with pkgs; [
            cmake
            ninja
            pkg-config
          ];

          buildInputs = with pkgs; [
            protobuf
            grpc
            abseil-cpp
          ];

          cmakeFlags = [
            "-DBUILD_SERVER=ON"
            "-DBUILD_CLIENT=OFF"
            "-DCMAKE_BUILD_TYPE=Release"
          ];

          buildPhase = ''
            cmake -B build -G Ninja $cmakeFlags
            cmake --build build --target grpc-server
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp build/grpc-server $out/bin/
          '';
        };

        # Build client
        client = pkgs.stdenv.mkDerivation {
          pname = "grpc-client";
          version = "1.0.0";
          src = ./.;

          nativeBuildInputs = with pkgs; [
            cmake
            ninja
            pkg-config
          ];

          buildInputs = with pkgs; [
            protobuf
            grpc
            abseil-cpp
          ];

          cmakeFlags = [
            "-DBUILD_SERVER=OFF"
            "-DBUILD_CLIENT=ON"
            "-DCMAKE_BUILD_TYPE=Release"
          ];

          buildPhase = ''
            cmake -B build -G Ninja $cmakeFlags
            cmake --build build --target grpc-client
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp build/grpc-client $out/bin/
          '';
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            cmake
            ninja
            gcc
            protobuf
            grpc
            abseil-cpp
            pkg-config
            grpcurl
            gdb
            valgrind
          ];

          shellHook = ''
            echo "C++ gRPC Development Shell"
            echo "Generated files available at: proto/gen/cpp/"
            echo ""
            echo "To build:"
            echo "  cmake -B build -G Ninja"
            echo "  cmake --build build"
            echo ""
            echo "To run server:"
            echo "  ./build/grpc-server"
            echo ""
            echo "To run client:"
            echo "  ./build/grpc-client"
            echo ""
            echo "To test with grpcurl:"
            echo "  grpcurl -plaintext localhost:50051 example.v1.GreeterService/SayHello"
          '';
        };

        packages = {
          inherit server client generated;
          default = server;
        };

        apps = {
          server = {
            type = "app";
            program = "${server}/bin/grpc-server";
          };
          client = {
            type = "app";
            program = "${client}/bin/grpc-client";
          };
        };
      }
    );
}

