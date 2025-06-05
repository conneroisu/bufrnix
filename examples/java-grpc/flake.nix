{
  description = "Java gRPC example with bufrnix";

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
        packages = [
          pkgs.gradle
          pkgs.maven
          pkgs.jdk17
          pkgs.protobuf_21
        ];
        shellHook = ''
          echo "Java gRPC Example"
          echo "Available commands:"
          echo "  nix build - Generate Java protobuf + gRPC code"
          echo "  gradle build - Build with Gradle (in gen/java/)"
          echo "  gradle runServer - Run the gRPC server"
          echo "  gradle runClient - Run the gRPC client"
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
              files = ["./proto/example/v1/greeter.proto"];
            };
            languages.java = {
              enable = true;
              package = pkgs.protobuf_21;
              jdk = pkgs.jdk17;
              outputPath = "gen/java";
              options = [];
              grpc = {
                enable = true;
                options = [];
              };
            };
          };
        };
      };
    });
}
