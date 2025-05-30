{
  description = "JavaScript gRPC-Web example using bufrnix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "path:../../..";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    bufrnix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      # Configure bufrnix for JavaScript with gRPC-Web
      protobufGenerated = bufrnix.lib.mkBufrnixPackage {
        inherit pkgs;

        config = {
          name = "js-grpc-web-example";
          src = ./.;

          # Enable JavaScript with gRPC-Web support
          languages.js = {
            enable = true;
            grpcWeb = {
              enable = true;
              importStyle = "typescript";
              mode = "grpcweb";
            };
          };
        };
      };
    in {
      packages.default = protobufGenerated;

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
    });
}
