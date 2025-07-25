{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix = {
      url = "path:../..";
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
        pkgs = nixpkgs.legacyPackages.${system};

        # Download gRPC Kotlin plugin JAR
        grpcKotlinJar = pkgs.fetchurl {
          url = "https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-kotlin/1.4.1/protoc-gen-grpc-kotlin-1.4.1-jdk8.jar";
          sha256 = "sha256-YqmVa0yarUoG7Lu11CXgeKA5HsV8Wia7+7sZ9nF7zWk=";
        };

        # Generate protobuf code with gRPC
        protoGen = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;

          config = {
            root = ./proto;
            languages = {
              kotlin = {
                enable = true;
                generateBuildFile = true;
                projectName = "KotlinGrpcExample";
                grpc = {
                  enable = true;
                  grpcKotlinJar = grpcKotlinJar;
                };
              };
            };
          };
        };
      in {
        packages = {
          default = protoGen;
          proto = protoGen;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            jdk17
            kotlin
            gradle
            protobuf
            grpc
          ];

          shellHook = ''
            echo "Kotlin gRPC Example Development Shell"
            echo "Run 'nix build .#proto' to generate proto code"
            echo "Run 'gradle build' to build the Kotlin project"
            echo "Run 'gradle runServer' to start the server"
            echo "Run 'gradle runClient' to run the client"
          '';
        };
      }
    );
}
