{
  description = "Protobuf Compiler/Codegen from Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
  };

  outputs = inputs @ {flake-utils, nixpkgs, systems, ...}: let
    # Define all supported systems explicitly
    supportedSystems = [
      "x86_64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  in
    {
      # Export the flake module for integration
      flakeModule = ./flake-module.nix;
      
      # Export a common library for all systems
      lib = {
        # Import options for use in other flakes
        options = import ./src/lib/bufrnix-options.nix { lib = nixpkgs.lib; };
        
        # Import debug utilities for use in other flakes
        debug = import ./src/lib/utils/debug.nix { lib = nixpkgs.lib; };
      };
      
      # Export NixOS modules that can be imported in configuration.nix
      nixosModules = {
        bufrnix = { config, lib, pkgs, ... }: {
          imports = [ ./src/module.nix ];
        };
        default = { config, lib, pkgs, ... }: {
          imports = [ ./src/module.nix ];
        };
      };
      
      # Export overlays for package customization
      overlays = {
        default = final: prev: {
          bufrnix = final.callPackage ./src/lib/mkBufrnix.nix { };
        };
      };
    }
    // flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = []; # No overlays needed for the base package
      };
      
      # Import the core mkBufrnix function
      mkBufrnixFunc = import ./src/lib/mkBufrnix.nix {
        inherit pkgs;
        lib = pkgs.lib;
      };
      
      # Import utility modules
      debug = import ./src/lib/utils/debug.nix { lib = pkgs.lib; };

      # Create the main package function with a simplified interface
      mkBufrnixPackage = {
        root ? "./proto",
        languages ? {},
        debug ? {},
      }: let
        # Build configuration object from parameters
        config = {
          inherit root;
          
          # Set debug configuration
          debug = {
            enable = debug.enable or false;
            verbosity = debug.verbosity or 1;
            logFile = debug.logFile or "";
          };
          
          # Set language configuration
          languages = {
            go = {
              enable = languages.go.enable or false;
              outputPath = languages.go.outputPath or "gen/go";
              options = languages.go.options or ["paths=source_relative"];
              packagePrefix = languages.go.packagePrefix or "";
              
              grpc = {
                enable = (languages.go.grpc.enable or false);
                options = languages.go.grpc.options or ["paths=source_relative"];
              };
            };
          };
          
          # Set protoc configuration
          protoc = {
            sourceDirectories = [root];
            includeDirectories = [root];
            files = [];
          };
        };
      in
        mkBufrnixFunc config;
      
      # Create Doc package
      docPackage = pkgs.stdenv.mkDerivation {
        pname = "bufrnix-docs";
        version = "0.1.0";
        src = ./doc;
        
        nativeBuildInputs = with pkgs; [
          mdbook
          mdbook-toc
          mdbook-linkcheck
        ];
        
        buildPhase = ''
          mdbook build
        '';
        
        installPhase = ''
          mkdir -p $out
          cp -r book/* $out/
        '';
      };
    in {
      # Package exports
      packages = {
        default = mkBufrnixPackage {};
        mkBufrnix = mkBufrnixFunc;
        doc = docPackage;
      };

      # App exports (for nix run)
      apps = {
        default = {
          type = "app";
          program = "${mkBufrnixPackage {}}/bin/bufrnix";
        };
        generate = {
          type = "app";
          program = "${(mkBufrnixPackage {}).runtimeInputs.path}/bin/bufrnix-generate";
        };
        lint = {
          type = "app";
          program = "${(mkBufrnixPackage {}).runtimeInputs.path}/bin/bufrnix-lint";
        };
        init = {
          type = "app";
          program = "${(mkBufrnixPackage {}).runtimeInputs.path}/bin/bufrnix-init";
        };
      };

      # Expose package functions and utilities as lib
      lib = {
        mkBufrnixPackage = mkBufrnixPackage;
        options = import ./src/lib/bufrnix-options.nix { lib = pkgs.lib; };
        debug = debug;
      };

      # Development shell with useful tools
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # Protobuf tools
          protobuf
          buf
          protoc-gen-go
          protoc-gen-go-grpc
          
          # Nix development tools
          alejandra     # Nix formatter
          statix        # Nix linter 
          deadnix       # Find unused code
          
          # Build our package with default settings
          (mkBufrnixPackage {})
        ];
        
        # Add useful environment variables
        shellHook = ''
          echo "Welcome to bufrnix development shell"
          echo "Available commands:"
          echo "  bufrnix generate - Generate protobuf code"
          echo "  bufrnix lint     - Lint protobuf files"
          echo "  format           - Format Nix files with alejandra"
          echo "  lint             - Lint Nix files with statix"
          
          # Command aliases
          alias format="alejandra ."
          alias lint="statix check"
        '';
      };
      
      # Add checks to ensure everything builds correctly
      checks = {
        build-default = mkBufrnixPackage {};
        build-with-go = mkBufrnixPackage {
          languages.go.enable = true;
        };
        build-with-go-grpc = mkBufrnixPackage {
          languages = {
            go = {
              enable = true;
              grpc.enable = true;
            };
          };
        };
        build-docs = docPackage;
      };
    });
}
