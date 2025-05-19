{
  description = "Bufrnix PHP Twirp example";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "github:conneroisu/bufrnix/php";
  };

  outputs = { self, nixpkgs, flake-utils, bufrnix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # Define PHP with required extensions
        phpWithExtensions = pkgs.php83.buildEnv {
          extensions = { enabled, all }: enabled ++ (with all; [
            curl
            mbstring
            tokenizer
            xml
            ctype
            fileinfo
            pdo
            dom
            iconv
            intl
            zip
            sodium
            openssl
          ]);
          extraConfig = ''
            memory_limit = 256M
            display_errors = On
            error_reporting = E_ALL
            date.timezone = UTC
          '';
        };

        # Create a bufrnix package for this project
        bufrnixPackage = bufrnix.lib.mkBufrnixPackage {
          inherit (nixpkgs.legacyPackages.${system}) lib;
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
              namespace = "Example\\Twirp";
              twirp = {
                enable = true;
              };
            };
          };
        };

        # Helper script to set up the project using bufrnix
        setupScript = pkgs.writeShellScriptBin "setup-twirp-php" ''
          #!/usr/bin/env bash
          set -euo pipefail
          
          echo "Setting up PHP Twirp example using bufrnix..."
          
          # Make sure the gen directory exists
          mkdir -p gen/php
          
          # Generate PHP code using bufrnix
          echo "Generating code with bufrnix..."
          ${bufrnixPackage}/bin/bufrnix
          
          # Verify PHP configuration
          echo "Checking PHP configuration..."
          if ! php -m | grep -q mbstring; then
            echo "Error: mbstring extension not available in PHP"
            echo "PHP modules loaded: $(php -m | sort | tr '\n' ' ')"
            exit 1
          fi
          
          if ! php -m | grep -q iconv && ! php -m | grep -q mbstring; then
            echo "Error: Neither iconv nor mbstring extension is available"
            echo "PHP modules loaded: $(php -m | sort | tr '\n' ' ')"
            exit 1
          fi
          
          # Install composer dependencies
          if [ -f "composer.json" ]; then
            echo "Installing PHP dependencies..."
            ${phpWithExtensions.packages.composer}/bin/composer install --no-interaction
          else
            echo "Warning: composer.json not found"
          fi
          
          echo "Setup complete! You can now run the example with:"
          echo "  run-server    # In one terminal"
          echo "  run-client    # In another terminal"
        '';

        # Helper script to run the server
        serverScript = pkgs.writeShellScriptBin "run-server" ''
          #!/usr/bin/env bash
          set -euo pipefail
          
          echo "Starting Twirp PHP server..."
          ${phpWithExtensions}/bin/php server.php
        '';

        # Helper script to run the client
        clientScript = pkgs.writeShellScriptBin "run-client" ''
          #!/usr/bin/env bash
          set -euo pipefail
          
          echo "Running Twirp PHP client..."
          ${phpWithExtensions}/bin/php client.php
        '';

      in {
        packages = {
          default = bufrnixPackage;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # PHP and Composer
            phpWithExtensions
            phpWithExtensions.packages.composer
            
            # Helper scripts
            setupScript
            serverScript
            clientScript
            
            # Include bufrnix package
            bufrnixPackage
          ];
          
          shellHook = ''
            export PROJECT_ROOT="$PWD"
            
            # PHP configuration
            export PHP_INI_SCAN_DIR="${phpWithExtensions}/lib/php/php.d"
            export PATH="${phpWithExtensions}/bin:${phpWithExtensions.packages.composer}/bin:$PATH"
            
            # Verify PHP configuration
            echo "Checking PHP configuration..."
            PHP_MODULES=$(${phpWithExtensions}/bin/php -m | sort)
            if ! echo "$PHP_MODULES" | grep -q mbstring; then
              echo "Warning: mbstring extension not available in PHP"
            fi
            
            if ! echo "$PHP_MODULES" | grep -q iconv; then
              echo "Warning: iconv extension not available in PHP"
            fi
            
            echo "==================================================="
            echo "Bufrnix PHP Twirp Example"
            echo "==================================================="
            echo "PHP version: $(${phpWithExtensions}/bin/php -v | head -n 1)"
            echo "Composer: $(${phpWithExtensions.packages.composer}/bin/composer --version)"
            echo ""
            echo "Available commands:"
            echo "  bufrnix           - Generate PHP code from proto files"
            echo "  setup-twirp-php   - Generate code and install dependencies"
            echo "  run-server        - Start the Twirp PHP server"
            echo "  run-client        - Run the Twirp PHP client"
            echo "==================================================="
          '';
        };

        # Add an app so users can run this with `nix run`
        apps.default = {
          type = "app";
          program = "${setupScript}/bin/setup-twirp-php";
        };
      }
    );
}
