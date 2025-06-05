{
  description = "JavaScript gRPC-Web example using bufrnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.url = "path:../..";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
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
        buildInputs = with pkgs; [
          nodejs_20
          nodePackages.typescript
          nodePackages.npm
          buf
          protobuf
          grpcurl
          envoy
        ];

        shellHook = ''
          echo "JavaScript gRPC-Web Example Development Shell"
          echo "Run 'nix build' to generate protobuf code"
          echo "Run 'npm install' to install dependencies"
          echo "Run 'npm run server' to start the gRPC server"
          echo "Run 'npm run proxy' to start the Envoy proxy"
          echo "Run 'npm run client' to run the client example"
        '';
      };

      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;

          config = {
            root = ./.;
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
              files = ["./proto/user.proto" "./proto/chat.proto"];
            };
            languages.js = {
              enable = true;
              outputPath = "proto/gen/js";
              packageName = "grpc-web-example";
              # Enable gRPC-Web support
              grpcWeb = {
                enable = true;
                importStyle = "commonjs";
                mode = "grpcweb";
              };
              # Disable ES modules to use traditional protoc-gen-js style
              # es = {
              #   enable = true;
              #   target = "js";
              # };
            };
          };
        };
      };
    });
}
