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
          # Allow for unfree packages like PHP extensions
          config.allowUnfree = true;
        };
        
        # Create a PHP package with extensions from external sources if needed
        phpWithExtensions = pkgs.php83.withExtensions ({ all }: [
          all.curl
          all.ctype
          all.dom
          all.iconv
          all.mbstring
          all.openssl
          all.pdo
          all.tokenizer
          all.xml
        ]);


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
          PHP_MODULES=$(${phpWithExtensions}/bin/php -m | sort)
          echo "PHP modules loaded: $(echo "$PHP_MODULES" | tr '\n' ' ')"
          
          # Check if mbstring is available
          if ${phpWithExtensions}/bin/php -m | grep -q mbstring; then
            echo "✓ mbstring extension is available"
          else
            echo "Warning: mbstring extension not available in PHP."
            echo "This may cause issues with the Twirp example."
          fi
          
          # Check if iconv is available
          if ${phpWithExtensions}/bin/php -m | grep -q iconv; then
            echo "✓ iconv extension is available"
          else
            echo "Warning: iconv extension not available in PHP."
            echo "This may cause issues with the Twirp example."
          fi
          
          # Install composer dependencies
          if [ -f "composer.json" ]; then
            echo "Installing PHP dependencies..."
            PATH="${phpWithExtensions}/bin:$PATH" ${phpWithExtensions.packages.composer}/bin/composer install --no-interaction
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
          PATH="${phpWithExtensions}/bin:$PATH" PHP_INI_SCAN_DIR="${phpWithExtensions}/lib/php/php.d" ${phpWithExtensions}/bin/php server.php
        '';

        # Helper script to run the client
        clientScript = pkgs.writeShellScriptBin "run-client" ''
          #!/usr/bin/env bash
          set -euo pipefail
          
          echo "Running Twirp PHP client..."
          PATH="${phpWithExtensions}/bin:$PATH" PHP_INI_SCAN_DIR="${phpWithExtensions}/lib/php/php.d" ${phpWithExtensions}/bin/php client.php
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
            
            # Create a workaround for mbstring missing in flake environment
            echo "Creating custom PHP wrapper to handle extension loading..."
            mkdir -p $PROJECT_ROOT/.nix-php
            
            # Create a custom php.ini that forces extension loading
            cat > $PROJECT_ROOT/.nix-php/php.ini << EOF
            extension=mbstring.so
            EOF
            
            # Create a custom PHP wrapper script
            cat > $PROJECT_ROOT/.nix-php/php-wrapper << EOF
            #!/bin/sh
            # Wrapper script to ensure mbstring is loaded
            PHP_INI_SCAN_DIR=$PROJECT_ROOT/.nix-php ${phpWithExtensions}/bin/php -n -c $PROJECT_ROOT/.nix-php/php.ini "\$@"
            EOF
            
            chmod +x $PROJECT_ROOT/.nix-php/php-wrapper
            export PATH="$PROJECT_ROOT/.nix-php:$PATH"
            
            # Check if we can use system PHP as a fallback
            if command -v /usr/bin/php >/dev/null; then
              if /usr/bin/php -m | grep -q mbstring; then
                echo "System PHP has mbstring available, using it as a fallback"
                echo "#!/bin/sh" > $PROJECT_ROOT/.nix-php/php
                echo "/usr/bin/php \"\$@\"" >> $PROJECT_ROOT/.nix-php/php
                chmod +x $PROJECT_ROOT/.nix-php/php
              fi
            fi
            
            # Verify PHP configuration
            echo "Checking PHP configuration..."
            PHP_MODULES=$(php -m | sort)
            echo "Available PHP modules:"
            echo "$PHP_MODULES"
            
            if ! echo "$PHP_MODULES" | grep -q mbstring; then
              echo "Warning: mbstring extension not available in PHP"
              echo "You may need to install PHP with mbstring support on your system"
              echo "sudo apt-get install php-mbstring  # For Debian/Ubuntu"
              echo "sudo dnf install php-mbstring     # For Fedora/RHEL"
              echo "Or modify client.php and server.php to work without mbstring"
            else
              echo "✓ mbstring extension is available"
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
