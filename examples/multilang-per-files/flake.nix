{
  description = "Multi-language per-files example demonstrating smart file separation between Go backend and JavaScript frontend";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.url = "path:../..";
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
    in {
      # Development shells for different languages
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # Multi-language development
            go
            nodejs
            typescript
            
            # Protobuf tools
            protobuf
            protoc-gen-go
            protoc-gen-go-grpc
            buf
          ];
          
          shellHook = ''
            echo "🚀 Multi-language Protobuf Development Environment"
            echo "================================================="
            echo ""
            echo "This example demonstrates per-language file configuration:"
            echo ""
            echo "📁 Project Structure:"
            echo "  • proto/common/     → Shared types (both Go & JS)"
            echo "  • proto/api/        → REST APIs with Google annotations (JS only)"
            echo "  • proto/internal/   → gRPC services (Go backend only)"
            echo "  • proto/google/api/ → Google annotations (JS only)"
            echo ""
            echo "🎯 Smart Exclusions:"
            echo "  • Go: Gets internal services, no Google annotations"
            echo "  • JS: Gets API definitions with Google annotations"
            echo ""
            echo "🧪 Commands:"
            echo "  • nix run              → Generate code for both languages"
            echo "  • cd backend && go run → Test Go backend"
            echo "  • cd frontend && npm start → Test JS frontend"
            echo ""
          '';
        };
        
        backend = pkgs.mkShell {
          packages = with pkgs; [
            go
            protoc-gen-go
            protoc-gen-go-grpc
            buf
          ];
          shellHook = ''
            echo "🐹 Go Backend Development"
            echo "Generated code: backend/generated/go/"
            cd backend
          '';
        };
        
        frontend = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            typescript
            nodePackages.tsx
          ];
          shellHook = ''
            echo "🌐 JavaScript/TypeScript Frontend Development"
            echo "Generated code: frontend/src/proto/generated/"
            cd frontend
          '';
        };
      };

      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;

          config = {
            root = ./.;
            
            # Global files (shared by all languages)
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
              files = [
                # Common types shared by both languages
                "./proto/common/v1/types.proto"
                "./proto/common/v1/status.proto"
              ];
            };

            # Enable debug to see per-language file processing
            debug = {
              enable = true;
              verbosity = 2;
            };

            languages = {
              # Go Backend Configuration
              go = {
                enable = true;
                outputPath = "backend/generated/go";
                
                # CRITICAL: Override global files - Go gets internal services but NO Google annotations
                # This prevents Go from generating Google API annotation files which would cause linting errors
                files = [
                  # Shared types (common to both languages)
                  "./proto/common/v1/types.proto"
                  "./proto/common/v1/status.proto"
                  # Backend-only internal services
                  "./proto/internal/v1/user_service.proto"
                  "./proto/internal/v1/admin_service.proto"
                  # NOTE: Deliberately excluding Google API annotations and public APIs
                  # This prevents generating unnecessary Go files that would cause linting errors
                ];
                
                # Enable gRPC for backend services
                grpc.enable = true;
                
                # Add validation for internal services
                validate.enable = true;
              };
              
              # JavaScript/TypeScript Frontend Configuration  
              js = {
                enable = true;
                outputPath = "frontend/src/proto/generated";
                
                # EXTEND: Use global files + additional frontend-specific files
                # Frontend gets public APIs + Google annotations, but no internal services
                additionalFiles = [
                  # Public API definitions with Google annotations
                  "./proto/api/v1/user_api.proto"
                  "./proto/api/v1/auth_api.proto"
                  # Google API annotations (needed for REST client generation)
                  "./proto/google/api/annotations.proto"
                  "./proto/google/api/http.proto"
                  # NOTE: Deliberately excluding internal services
                  # Frontend should not have access to backend-only operations
                ];
                
                # Modern TypeScript generation
                es = {
                  enable = true;
                  options = [
                    "target=ts"
                    "import_extension=.js" 
                    "json_types=true"
                    "keep_empty_files=true"
                  ];
                };
              };
            };
          };
        };
      };
    });
}