{
  description = "PHP gRPC with RoadRunner Generation using Bufrnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    bufrnix,
    ...
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
      };
    });
}
