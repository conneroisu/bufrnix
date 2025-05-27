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

  outputs = { self, nixpkgs, flake-utils, bufrnix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        bufrnixLib = bufrnix.lib.${system};
      in
      {
        devShells.default = bufrnixLib.mkShell {
          name = "php-grpc-roadrunner-example";

          # Configure PHP with all new features
          languages.php = {
            enable = true;
            outputPath = "gen/php";
            
            namespace = "App\\Proto";
            metadataNamespace = "Metadata";
            
            composer = {
              enable = true;
              autoInstall = true;
            };
            
            # Enable gRPC support
            grpc = {
              enable = true;
              serviceNamespace = "Services";
            };
            
            # Enable RoadRunner for high-performance server
            roadrunner = {
              enable = true;
              workers = 4;
              maxJobs = 100;
              maxMemory = 128;
            };
            
            # Enable Laravel framework integration
            frameworks.laravel.enable = false; # Set to true if using Laravel
            
            # Enable async PHP features
            async = {
              reactphp = {
                enable = true;
                version = "^1.0";
              };
              swoole = {
                enable = true;
                coroutines = true;
              };
              fibers.enable = true;
            };
          };

          # Proto configuration
          proto = {
            directories = [ "./proto" ];
          };

          # Additional development tools
          packages = with pkgs; [
            # Development tools
            git
            curl
            jq
            
            # PHP development
            php82Packages.composer
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