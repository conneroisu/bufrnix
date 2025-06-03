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

        # Generate protobuf code with gRPC
        protoGen = bufrnix.lib.mkBufrnixPackage {
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
        server = pkgs.callPackage ./Server {
          inherit pkgs;
        };

        # Build the client application
        client = pkgs.callPackage ./Client {
          inherit pkgs;
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
            nuget-to-json
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
