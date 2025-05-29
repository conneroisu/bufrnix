{
  description = "Advanced Go protobuf example with performance plugins";

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
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            protobuf
            protoc-gen-go
            protoc-gen-go-grpc
            # These packages are now provided by bufrnix defaults
            buf
          ];
        };

        packages = {
          default = bufrnix.lib.mkBufrnixPackage {
            inherit (pkgs) lib;
            inherit pkgs;
            config = {
              root = ".";
              protoc = {
                includeDirectories = ["proto"];
              };

              languages = {
                go = {
                  enable = true;
                  outputPath = "proto/gen/go";

                  # Example 1: Using individual plugin configurations
                  grpc.enable = true;
                  openapiv2 = {
                    enable = true;
                    outputPath = "proto/gen/openapi";
                  };
                  vtprotobuf = {
                    enable = true;
                    options = [
                      "paths=source_relative"
                      "features=marshal+unmarshal+size+pool"
                    ];
                  };
                  json.enable = true;

                  # Example 2: Using the new plugins list with Buf registry names
                  # (This would be an alternative to the above configuration)
                  # plugins = [
                  #   "buf.build/protocolbuffers/go"
                  #   "buf.build/grpc/go"
                  #   {
                  #     plugin = "buf.build/community/planetscale-vtprotobuf";
                  #     opt = ["features=marshal+unmarshal+size+pool"];
                  #   }
                  #   "buf.build/community/mfridman-go-json"
                  #   "openapiv2"
                  # ];
                };
              };
            };
          };
        };
      }
    );
}
