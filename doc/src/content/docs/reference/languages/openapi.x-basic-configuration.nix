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
        packages = {
          default = bufrnix.lib.mkBufrnixPackage {
            inherit pkgs;
            config = {
              root = ".";
              protoc = {
                includeDirectories = ["proto"];
                files = ["proto/api/v1/service.proto"];
              };

              languages = {
                # Generate Go code with gRPC and Gateway
                go = {
                  enable = true;
                  outputPath = "gen/go";
                  grpc.enable = true;
                  gateway.enable = true;
                };

                # Generate OpenAPI v2 specifications
                openapi = {
                  enable = true;
                  outputPath = "gen/openapi";
                  options = [
                    "logtostderr=true"
                    "allow_merge=true"
                    "merge_file_name=api"
                  ];
                };

                # Generate TypeScript client
                js = {
                  enable = true;
                  outputPath = "gen/js";
                  es.enable = true;
                  connect.enable = true;
                };
              };
            };
          };
        };
      }
    );
}