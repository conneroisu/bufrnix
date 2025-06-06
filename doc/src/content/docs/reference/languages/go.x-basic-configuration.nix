{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix = {
      url = "github:conneroisu/bufrnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    bufrnix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            protobuf
            protoc-gen-go
            protoc-gen-go-grpc
            buf
          ];
        };

        packages = {
          default = bufrnix.lib.mkBufrnixPackage {
            inherit pkgs;
            config = {
              root = ".";
              protoc = {
                includeDirectories = ["proto"];
                files = ["proto/example/v1/user.proto"];
              };

              languages = {
                go = {
                  enable = true;
                  outputPath = "proto/gen/go";

                  # gRPC support
                  grpc.enable = true;

                  # OpenAPI v2 generation
                  openapiv2 = {
                    enable = true;
                    outputPath = "proto/gen/openapi";
                  };

                  # High-performance vtprotobuf plugin
                  vtprotobuf = {
                    enable = true;
                    options = [
                      "paths=source_relative"
                      "features=marshal+unmarshal+size+pool"
                    ];
                  };

                  # JSON marshaling support
                  json.enable = true;
                };
              };
            };
          };
        };
      }
    );
}
