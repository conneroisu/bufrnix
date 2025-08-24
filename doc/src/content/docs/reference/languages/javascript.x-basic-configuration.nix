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
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.nodejs
          pkgs.nodePackages.typescript
        ];
      };
      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;

          config = {
            root = ./.;
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
              files = ["./proto/example/v1/example.proto"];
            };
            languages.js = {
              enable = true;
              outputPath = "proto/gen/js";
              packageName = "example-proto";
              
              # Per-language file control (new feature)
              # files = [
              #   "./proto/common/v1/types.proto"
              #   "./proto/api/v1/user_api.proto"
              # ];
              # additionalFiles = [
              #   "./proto/google/api/annotations.proto"  # For Connect-ES REST clients
              #   "./proto/google/api/http.proto"
              # ];

              # Modern JavaScript with ECMAScript modules
              es = {
                enable = true;
              };
            };
          };
        };
      };
    });
}
