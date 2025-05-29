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

        # Generate protobuf code with gRPC
        protoGen = bufrnix.lib.mkBufrnixPackage {
          inherit (pkgs) lib;
          inherit pkgs;
          config = {
            root = ./proto;
            languages = {
              csharp = {
                enable = true;
                namespace = "GreeterProtos";
                generateProjectFile = true;
                projectName = "GreeterProtos";
                grpc = {
                  enable = true;
                };
              };
            };
          };
        };

        # Build the server application
        server = pkgs.buildDotnetModule {
          pname = "csharp-grpc-server";
          version = "1.0.0";

          src = ./.;

          projectFile = "Server/Server.csproj";
          nugetDeps = ./deps.nix;

          dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
          dotnet-runtime = pkgs.dotnetCorePackages.aspnetcore_8_0;

          configurePhase = ''
            runHook preConfigure

            # Generate proto code before dotnet restore tries to find the project references
            echo "Generating protobuf code with bufrnix..."
            ${protoGen}/bin/bufrnix

            # List all generated files to see where they actually are
            echo "Searching for generated .cs files:"
            find . -name "*.cs" -type f | grep -v Program.cs
            echo "Directory structure:"
            find . -type d | head -20

            # Now run the normal dotnet configure
            dotnetConfigureHook

            runHook postConfigure
          '';
        };

        # Build the client application
        client = pkgs.buildDotnetModule {
          pname = "csharp-grpc-client";
          version = "1.0.0";

          src = ./.;

          projectFile = "Client/Client.csproj";
          nugetDeps = ./deps.nix;

          dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
          dotnet-runtime = pkgs.dotnetCorePackages.runtime_8_0;

          configurePhase = ''
            runHook preConfigure

            # Generate proto code before dotnet restore tries to find the project references
            echo "Generating protobuf code with bufrnix..."
            ${protoGen}/bin/bufrnix

            # List all generated files to see where they actually are
            echo "Searching for generated .cs files:"
            find . -name "*.cs" -type f | grep -v Program.cs
            echo "Directory structure:"
            find . -type d | head -20

            # Now run the normal dotnet configure
            dotnetConfigureHook

            runHook postConfigure
          '';
        };
      in {
        packages = {
          inherit server client;
          proto = protoGen;
          default = protoGen;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            dotnetCorePackages.sdk_8_0
            protobuf
            grpc
          ];

          shellHook = ''
            echo "C# gRPC Example Development Shell"
            echo "Run 'nix build .#proto' to generate proto code"
            echo "Run 'nix build .#server' to build the server"
            echo "Run 'nix build .#client' to build the client"
            echo ""
            echo "Or use dotnet directly:"
            echo "  cd Server && dotnet run"
            echo "  cd Client && dotnet run"
          '';
        };
      }
    );
}
