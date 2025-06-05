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

        # Generate protobuf code
        protoGen = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;

          config = {
            root = ./proto;
            languages = {
              kotlin = {
                enable = true;
                generateBuildFile = true;
                projectName = "KotlinProtoExample";
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
          ];

          shellHook = ''
            echo "Kotlin Proto Example Development Shell"
            echo "Run 'nix build .#proto' to generate proto code"
            echo "Run 'gradle build' to build the Kotlin project"
            echo "Run 'gradle run' to execute the example"
          '';
        };
      }
    );
}
