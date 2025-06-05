{
  description = "Multi-project Go protobuf example with multiple proto source files";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "path:../..";
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
                files = [
                  "proto/users/v1/user.proto"
                  "proto/orders/v1/order.proto"
                  "proto/products/v1/product.proto"
                ];
              };

              languages = {
                go = {
                  enable = true;
                  outputPath = "proto/gen/go";
                  grpc.enable = true;
                };
              };
            };
          };
        };
      }
    );
}