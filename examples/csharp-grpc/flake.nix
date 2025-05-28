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
        protoGen = bufrnix.lib.${system}.mkBufrnix {
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

        # Build the server application
        server = pkgs.buildDotnetModule {
          pname = "csharp-grpc-server";
          version = "1.0.0";
          
          src = ./.;
          
          projectFile = "Server/Server.csproj";
          nugetDeps = ./deps.nix;
          
          dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
          dotnet-runtime = pkgs.dotnetCorePackages.aspnetcore_8_0;
          
          preBuild = ''
            # Copy generated proto code
            mkdir -p Generated
            cp -r ${protoGen}/gen/csharp/* ./Generated/
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
          
          preBuild = ''
            # Copy generated proto code
            mkdir -p Generated
            cp -r ${protoGen}/gen/csharp/* ./Generated/
          '';
        };
      in {
        packages = {
          default = server;
          inherit server client;
          proto = protoGen;
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