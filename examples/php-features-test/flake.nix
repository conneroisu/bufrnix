{
  description = "Comprehensive PHP features test for Bufrnix";

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
        devShells = {
          # Test 1: Basic PHP protobuf generation with custom namespaces
          basic = bufrnixLib.mkShell {
            name = "php-basic-test";
            
            languages.php = {
              enable = true;
              outputPath = "gen/php/basic";
              namespace = "BasicTest\\Messages";
              metadataNamespace = "BasicTest\\Meta";
              classPrefix = "BT";
              
              composer = {
                enable = true;
                autoInstall = false;
              };
            };
            
            proto.directories = [ "./proto" ];
          };
          
          # Test 2: PHP with gRPC support
          grpc = bufrnixLib.mkShell {
            name = "php-grpc-test";
            
            languages.php = {
              enable = true;
              outputPath = "gen/php/grpc";
              namespace = "GrpcTest\\Proto";
              
              grpc = {
                enable = true;
                serviceNamespace = "Svc";
                clientOnly = false;
              };
              
              composer.enable = true;
            };
            
            proto.directories = [ "./proto" ];
          };
          
          # Test 3: PHP with RoadRunner
          roadrunner = bufrnixLib.mkShell {
            name = "php-roadrunner-test";
            
            languages.php = {
              enable = true;
              outputPath = "gen/php/roadrunner";
              namespace = "RoadRunner\\Test";
              
              grpc.enable = true;
              
              roadrunner = {
                enable = true;
                workers = 2;
                maxJobs = 50;
                maxMemory = 64;
                tlsEnabled = false;
              };
            };
            
            proto.directories = [ "./proto" ];
          };
          
          # Test 4: Laravel integration
          laravel = bufrnixLib.mkShell {
            name = "php-laravel-test";
            
            languages.php = {
              enable = true;
              outputPath = "gen/php/laravel";
              namespace = "Laravel\\Proto";
              
              grpc.enable = true;
              roadrunner.enable = true;
              
              frameworks.laravel = {
                enable = true;
                serviceProvider = true;
                artisanCommands = true;
              };
            };
            
            proto.directories = [ "./proto" ];
          };
          
          # Test 5: Symfony integration
          symfony = bufrnixLib.mkShell {
            name = "php-symfony-test";
            
            languages.php = {
              enable = true;
              outputPath = "gen/php/symfony";
              namespace = "Symfony\\Proto";
              
              grpc.enable = true;
              
              frameworks.symfony = {
                enable = true;
                bundle = true;
                messengerIntegration = true;
              };
            };
            
            proto.directories = [ "./proto" ];
          };
          
          # Test 6: Async PHP with all options
          async = bufrnixLib.mkShell {
            name = "php-async-test";
            
            languages.php = {
              enable = true;
              outputPath = "gen/php/async";
              namespace = "AsyncPHP\\Proto";
              
              grpc.enable = true;
              
              async = {
                reactphp = {
                  enable = true;
                  version = "^1.3";
                };
                
                swoole = {
                  enable = true;
                  coroutines = true;
                };
                
                fibers = {
                  enable = true;
                };
              };
            };
            
            proto.directories = [ "./proto" ];
          };
          
          # Test 7: Full-featured configuration
          full = bufrnixLib.mkShell {
            name = "php-full-test";
            
            languages.php = {
              enable = true;
              outputPath = "gen/php/full";
              namespace = "FullTest\\Proto";
              metadataNamespace = "FullTest\\Metadata";
              classPrefix = "FT";
              
              composer = {
                enable = true;
                autoInstall = true;
              };
              
              grpc = {
                enable = true;
                serviceNamespace = "Services";
                clientOnly = false;
              };
              
              roadrunner = {
                enable = true;
                workers = 4;
                maxJobs = 100;
                maxMemory = 128;
                tlsEnabled = true;
              };
              
              frameworks = {
                laravel = {
                  enable = true;
                  serviceProvider = true;
                  artisanCommands = true;
                };
              };
              
              async = {
                reactphp = {
                  enable = true;
                  version = "^1.0";
                };
                
                swoole = {
                  enable = true;
                  coroutines = true;
                };
                
                fibers = {
                  enable = true;
                };
              };
            };
            
            proto.directories = [ "./proto" ];
            
            packages = with pkgs; [
              php82Packages.psalm
              php82Packages.php-cs-fixer
            ];
          };
          
          # Test 8: Client-only gRPC generation
          clientOnly = bufrnixLib.mkShell {
            name = "php-client-only-test";
            
            languages.php = {
              enable = true;
              outputPath = "gen/php/client";
              namespace = "ClientOnly\\Proto";
              
              grpc = {
                enable = true;
                clientOnly = true;
                serviceNamespace = "Client";
              };
            };
            
            proto.directories = [ "./proto" ];
          };
          
          # Default shell with all tests script
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              bash
              php82
              php82Packages.composer
            ];
            
            shellHook = ''
              echo "PHP Features Test Suite"
              echo "======================"
              echo ""
              echo "Available test shells:"
              echo "  nix develop .#basic      - Basic protobuf generation"
              echo "  nix develop .#grpc       - gRPC client/server"
              echo "  nix develop .#roadrunner - RoadRunner server"
              echo "  nix develop .#laravel    - Laravel integration"
              echo "  nix develop .#symfony    - Symfony integration"
              echo "  nix develop .#async      - Async PHP (ReactPHP, Swoole, Fibers)"
              echo "  nix develop .#full       - All features combined"
              echo "  nix develop .#clientOnly - Client-only gRPC"
              echo ""
              echo "Run ./test-all.sh to test all configurations"
            '';
          };
        };
      });
}