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
        };
      in {
        packages = {
          default = protoGen;
          proto = protoGen;
          inherit app;
        };

        apps.app = {
          type = "app";
          program = "${app}/bin/CSharpExample";
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
