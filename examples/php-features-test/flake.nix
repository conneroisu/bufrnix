{
  description = "Comprehensive PHP features test/example for Bufrnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # bufrnix.url = "github:conneroisu/bufrnix";
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

      # Helper to create a bufrnix package with given config
      mkBufrnixPkg = config:
        bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;
          inherit config;
        };
    in {
      packages = {
        # Test 1: Basic PHP protobuf generation with custom namespaces
        basic = mkBufrnixPkg {
          root = ./.;
          protoc = {
            sourceDirectories = ["./proto"];
            includeDirectories = ["./proto"];
          };

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
        };

        # Test 2: PHP with gRPC support
        grpc = mkBufrnixPkg {
          root = ./.;
          protoc = {
            sourceDirectories = ["./proto"];
            includeDirectories = ["./proto"];
          };

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
        };

        # Test 3: PHP with RoadRunner
        roadrunner = mkBufrnixPkg {
          root = ./.;
          protoc = {
            sourceDirectories = ["./proto"];
            includeDirectories = ["./proto"];
          };

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
        };

        # Test 4: Laravel integration
        laravel = mkBufrnixPkg {
          root = ./.;
          protoc = {
            sourceDirectories = ["./proto"];
            includeDirectories = ["./proto"];
          };

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
        };

        # Test 5: Symfony integration
        symfony = mkBufrnixPkg {
          root = ./.;
          protoc = {
            sourceDirectories = ["./proto"];
            includeDirectories = ["./proto"];
          };

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
        };

        # Test 6: Async PHP with all options
        async = mkBufrnixPkg {
          root = ./.;
          protoc = {
            sourceDirectories = ["./proto"];
            includeDirectories = ["./proto"];
          };

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
        };

        # Test 7: Full-featured configuration
        full = mkBufrnixPkg {
          root = ./.;
          protoc = {
            sourceDirectories = ["./proto"];
            includeDirectories = ["./proto"];
          };

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
        };

        # Test 8: Client-only gRPC generation
        clientOnly = mkBufrnixPkg {
          root = ./.;
          protoc = {
            sourceDirectories = ["./proto"];
            includeDirectories = ["./proto"];
          };

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
        };
      };

      devShells = {
        # Test shells for each configuration
        basic = pkgs.mkShell {
          buildInputs = [self.packages.${system}.basic];
        };
        grpc = pkgs.mkShell {
          buildInputs = [self.packages.${system}.grpc];
        };
        roadrunner = pkgs.mkShell {
          buildInputs = [self.packages.${system}.roadrunner];
        };
        laravel = pkgs.mkShell {
          buildInputs = [self.packages.${system}.laravel];
        };
        symfony = pkgs.mkShell {
          buildInputs = [self.packages.${system}.symfony];
        };
        async = pkgs.mkShell {
          buildInputs = [self.packages.${system}.async];
        };
        full = pkgs.mkShell {
          buildInputs = [self.packages.${system}.full];
        };
        clientOnly = pkgs.mkShell {
          buildInputs = [self.packages.${system}.clientOnly];
        };

        # Default shell with all tests script
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bash
            php82
            php82Packages.composer
            buf
          ];

          shellHook = ''
            echo "PHP Features Test Suite"
            echo "======================"
            echo ""
            echo "Available test packages:"
            echo "  nix build .#basic      - Basic protobuf generation"
            echo "  nix build .#grpc       - gRPC client/server"
            echo "  nix build .#roadrunner - RoadRunner server"
            echo "  nix build .#laravel    - Laravel integration"
            echo "  nix build .#symfony    - Symfony integration"
            echo "  nix build .#async      - Async PHP (ReactPHP, Swoole, Fibers)"
            echo "  nix build .#full       - All features combined"
            echo "  nix build .#clientOnly - Client-only gRPC"
            echo ""
            echo "Run ./test-all.sh to test all configurations"
          '';
        };
      };
    });
}
