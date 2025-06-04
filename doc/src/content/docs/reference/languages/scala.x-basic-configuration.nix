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
        pkgs = nixpkgs.legacyPackages.${system};

        # Generate protobuf code
        protoGen = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;

          config = {
            root = ./proto;
            languages = {
              scala = {
                enable = true;
                generateBuildFile = true;
                projectName = "ScalaProtoExample";
                organization = "com.example.protobuf";
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
            sbt
            scala_3
            protobuf
          ];

          shellHook = ''
            echo "Scala Proto Example Development Shell"
            echo "Run 'nix run' to generate proto code"
            echo ""
            echo "For development:"
            echo "  1. Generate protos: nix run"
            echo "  2. Compile: sbt compile"
            echo "  3. Run: sbt run"
          '';
        };
        
        apps = {
          default = {
            type = "app";
            program = "${protoGen}/bin/bufrnix";
          };
        };
      }
    );
}