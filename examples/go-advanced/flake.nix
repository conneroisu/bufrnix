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

        # Define custom packages for plugins not yet in nixpkgs
        protoc-gen-openapiv2 = pkgs.buildGoModule rec {
          pname = "protoc-gen-openapiv2";
          version = "2.19.0";

          src = pkgs.fetchFromGitHub {
            owner = "grpc-ecosystem";
            repo = "grpc-gateway";
            rev = "v${version}";
            sha256 = "sha256-zLAIZce0A2G5q6orevUGkgKEQhgXutpyJJaWLqVaOqA=";
          };

          vendorHash = "sha256-S4hcD5/BSGxM2qdJHMxOkxsJ5+Ks6m4lKHSS9+yZ17c=";
          subPackages = ["protoc-gen-openapiv2"];
        };

        protoc-gen-go-vtproto = pkgs.buildGoModule rec {
          pname = "protoc-gen-go-vtproto";
          version = "0.6.0";

          src = pkgs.fetchFromGitHub {
            owner = "planetscale";
            repo = "vtprotobuf";
            rev = "v${version}";
            sha256 = "sha256-iNgDZRjmzFqgtkTiZdQ2f3mS8L6RiqnSJJJP2p8/RJE=";
          };

          vendorHash = "sha256-JpSVO8h7+StLG9/dJQkmrIlh9zIHABoqP7jkDzHT18w=";
          subPackages = ["cmd/protoc-gen-go-vtproto"];
        };

        protoc-gen-go-json = pkgs.buildGoModule rec {
          pname = "protoc-gen-go-json";
          version = "1.4.0";

          src = pkgs.fetchFromGitHub {
            owner = "mfridman";
            repo = "protoc-gen-go-json";
            rev = "v${version}";
            sha256 = "sha256-g3Rc9cpONI6+FiXcMG9H8go6J7i+hsvcQG8OREMqaKU=";
          };

          vendorHash = "sha256-8G8u5gXOcFiqOKwdrj8RKNp8l8X/lLIDkudginm7JPw=";
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            protobuf
            protoc-gen-go
            protoc-gen-go-grpc
            protoc-gen-openapiv2
            protoc-gen-go-vtproto
            protoc-gen-go-json
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
                    package = protoc-gen-openapiv2;
                  };
                  vtprotobuf = {
                    enable = true;
                    package = protoc-gen-go-vtproto;
                    options = [
                      "paths=source_relative"
                      "features=marshal+unmarshal+size+pool"
                    ];
                  };
                  json = {
                    enable = true;
                    package = protoc-gen-go-json;
                  };

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
