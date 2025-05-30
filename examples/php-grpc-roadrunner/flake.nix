{
  description = "PHP gRPC with RoadRunner example using Bufrnix";

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
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Create a bufrnix package for this project
      bufrnixPackage = bufrnix.lib.mkBufrnixPackage {
        inherit pkgs;
        
        config = {
          root = ./.;
          debug.enable = true;
          protoc = {
            sourceDirectories = ["./proto"];
            includeDirectories = ["./proto"];
          };
          languages.php = {
            enable = true;
            outputPath = "gen/php";
            namespace = "";
            metadataNamespace = "";
            
            # Enable gRPC support
            grpc = {
              enable = true;
              serviceNamespace = "Services";
              clientOnly = false;  # Generate both client and server code
            };
            
            # Enable RoadRunner for server interfaces
            roadrunner = {
              enable = true;
              workers = 4;
              maxJobs = 100;
              maxMemory = 128;
            };
          };
        };
      };
    in {
      packages = {
        default = bufrnixPackage;
      };

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Core tools
          bufrnixPackage
          php82
          php82Packages.composer
          
          # Development tools
          git
          curl
          jq
          
          # PHP development
          php82Packages.psalm
          php82Packages.php-cs-fixer
        ];

        shellHook = ''
          echo "🚀 PHP gRPC + RoadRunner Development Environment"
          echo "================================================"
          echo ""
          echo "Available commands:"
          echo "  buf generate    - Generate PHP code from proto files"
          echo "  buf lint        - Lint proto files"
          echo "  buf breaking    - Check for breaking changes"
          echo ""
          echo "PHP/Composer commands:"
          echo "  composer install          - Install dependencies"
          echo "  composer dump-autoload    - Regenerate autoloader"
          echo ""
          echo "RoadRunner commands:"
          echo "  ./roadrunner-dev.sh start   - Start RoadRunner server"
          echo "  ./roadrunner-dev.sh debug   - Start in debug mode"
          echo "  ./roadrunner-dev.sh workers - Check worker status"
          echo ""
          echo "Testing:"
          echo "  php test-client.php      - Run test client"
          echo "  php test-async.php       - Run async examples"
          echo ""

          # Initialize project structure
          mkdir -p proto/example/v1
          mkdir -p src/Services
          mkdir -p tests
        '';
      };
    });
}
