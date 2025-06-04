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

        # Script to run both server and client
        runDemo = pkgs.writeShellScriptBin "run-demo" ''
          set -e
          
          echo "🚀 Starting C# gRPC Demo..."
          echo "================================"
          
          # Check if we're in the right directory
          if [[ ! -d "Server" || ! -d "Client" ]]; then
            echo "❌ Error: Server and Client directories not found!"
            echo "Please run this command from the csharp-grpc example directory."
            exit 1
          fi
          
          # Start server in background
          echo "📡 Starting gRPC server..."
          cd Server
          ${pkgs.dotnetCorePackages.sdk_8_0}/bin/dotnet run &
          SERVER_PID=$!
          cd ..
          
          # Wait for server to start
          echo "⏳ Waiting for server to be ready..."
          sleep 5
          
          # Trap to cleanup server on exit
          trap "echo '🛑 Stopping server...'; kill $SERVER_PID 2>/dev/null || true; wait $SERVER_PID 2>/dev/null || true" EXIT
          
          # Run client
          echo "📞 Running gRPC client..."
          echo "================================"
          cd Client
          ${pkgs.dotnetCorePackages.sdk_8_0}/bin/dotnet run
          cd ..
          
          echo "================================"
          echo "✅ Demo completed successfully!"
        '';
      in {
        packages = {
          inherit server client runDemo;
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
            echo "================================="
            echo "📦 Build commands:"
            echo "  nix build .#proto   - Generate proto code"
            echo "  nix build .#server  - Build the server"
            echo "  nix build .#client  - Build the client"
            echo ""
            echo "🚀 Run commands:"
            echo "  nix run .#runDemo   - Run complete demo (server + client)"
            echo ""
            echo "🔧 Manual dotnet commands:"
            echo "  cd Server && dotnet run"
            echo "  cd Client && dotnet run"
          '';
        };
      }
    );
}
