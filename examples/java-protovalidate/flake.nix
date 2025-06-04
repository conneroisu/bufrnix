{
  description = "Java protovalidate example with bufrnix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bufrnix.url = "path:../..";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    bufrnix,
    ...
  }: let
    allSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs allSystems (system:
        f {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};
        });
  in {
    packages = forAllSystems ({
      system,
      pkgs,
    }: {
      default = bufrnix.lib.mkBufrnixPackage {
        inherit pkgs;
        config = {
          root = ./.;
          protoc = {
            sourceDirectories = ["./proto"];
            includeDirectories = ["./proto"];
            files = [
              "./proto/buf/validate/validate.proto"
              "./proto/example/v1/user.proto"
            ];
          };
          languages = {
            java = {
              enable = true;
              outputPath = "gen/java";
              options = [];
              protovalidate.enable = true;
            };
          };
        };
      };
    });

    devShells = forAllSystems ({
      system,
      pkgs,
    }: {
      default = pkgs.mkShell {
        buildInputs = [
          pkgs.gradle
          pkgs.maven
          pkgs.jdk17
          pkgs.protobuf
        ];

        shellHook = ''
          echo "Java Protovalidate Example"
          echo "Available commands:"
          echo "  nix build - Generate Java protobuf code with protovalidate"
          echo "  cd gen/java && gradle build - Build with Gradle"
          echo "  cd gen/java && gradle run - Run the validation example"
        '';
      };
    });
  };
}
