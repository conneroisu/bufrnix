{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix = {
      url = "path:../..";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    bufrnix,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        # Generate protobuf code
        protoGen = bufrnix.lib.mkBufrnixPackage {
          inherit (pkgs) lib;
          inherit pkgs;
          config = {
            root = ./proto;
            languages = {
              csharp = {
                enable = true;
                namespace = "ExampleProtos";
                generateProjectFile = true;
                projectName = "ExampleProtos";
              };
            };
          };
        };

        # Build the C# application
        app = pkgs.buildDotnetModule {
          pname = "csharp-proto-example";
          version = "1.0.0";

          src = ./.;

          projectFile = "CSharpExample.csproj";
          nugetDeps = ./deps.nix;

          dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
          dotnet-runtime = pkgs.dotnetCorePackages.runtime_8_0;

          preBuild = ''
            # Generate proto code by running the bufrnix script
            ${protoGen}/bin/bufrnix
            # Copy generated proto code
            mkdir -p Generated
            cp -r proto/gen/csharp/* ./Generated/
          '';
        };
      in {
        packages = {
          default = app;
          proto = protoGen;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            dotnetCorePackages.sdk_8_0
            protobuf
            grpc
          ];

          shellHook = ''
            echo "C# Proto Example Development Shell"
            echo "Run 'nix build .#proto' to generate proto code"
            echo "Run 'nix build' to build the application"
            echo "Run 'dotnet run' to run the application"
          '';
        };
      }
    );
}
