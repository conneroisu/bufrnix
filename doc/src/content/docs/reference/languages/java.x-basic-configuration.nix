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
    self,
    nixpkgs,
    flake-utils,
    bufrnix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.gradle
          pkgs.maven
          pkgs.jdk17
          pkgs.protobuf
        ];
        shellHook = ''
          echo "Java Basic Protobuf Example"
          echo "Available commands:"
          echo "  nix build - Generate Java protobuf code"
          echo "  gradle build - Build with Gradle (in gen/java/)"
          echo "  mvn compile exec:java -Dexec.mainClass='com.example.Main' - Build and run with Maven (in gen/java/)"
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
              files = ["./proto/example/v1/person.proto"];
            };
            languages.java = {
              enable = true;
              package = pkgs.protobuf;
              jdk = pkgs.jdk17;
              outputPath = "gen/java";
              options = [];

              # Per-language file control (new feature)
              # files = [
              #   "./proto/common/v1/types.proto"
              #   "./proto/enterprise/v1/billing_service.proto"
              # ];
              # additionalFiles = [
              #   "./proto/google/cloud/pubsub/v1/pubsub.proto"
              #   "./proto/third_party/kafka/kafka.proto"
              # ];
            };
          };
        };
      };
    });
}
