{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
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
              scala = {
                enable = true;
                generateBuildFile = true;
                projectName = "ScalaProtoExample";
                organization = "com.example.protobuf";
              };
            };
          };
        };
        # Script to run the Scala application
        runScript = pkgs.writeShellScriptBin "run-scala-example" ''
          set -e
          
          # Create a temporary directory for the example
          tmpdir=$(mktemp -d)
          echo "Working in temporary directory: $tmpdir"
          
          # Copy the source files
          cp -r ${./.}/* $tmpdir/
          cd $tmpdir
          
          # Generate protobuf files
          echo "Generating protobuf files..."
          ${protoGen}/bin/bufrnix
          
          # Run the application with sbt
          echo "Running Scala example..."
          ${pkgs.sbt}/bin/sbt -J-Xmx2G run
          
          # Clean up
          rm -rf $tmpdir
        '';
      in {
        packages = {
          default = protoGen;
          proto = protoGen;
          run = runScript;
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
            echo "Run 'nix run .#example' to execute the example"
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
          example = {
            type = "app";
            program = "${runScript}/bin/run-scala-example";
          };
        };
      }
    );
}