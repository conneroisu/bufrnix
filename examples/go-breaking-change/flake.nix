{
  description = "Bufrnix example demonstrating breaking change detection for Protocol Buffer schemas";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.url = "path:../..";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    bufrnix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          go
          git
          buf
        ];

        shellHook = ''
          echo "🔧 Breaking Change Detection Example"
          echo ""
          echo "This example demonstrates Bufrnix's breaking change detection feature."
          echo ""
          echo "Commands:"
          echo "  nix run                    - Generate code with breaking change detection"
          echo "  git log --oneline -5       - View recent commits to understand changes"
          echo "  buf breaking --against .git#branch=HEAD~1  - Run buf breaking manually"
          echo ""
          echo "Try making a breaking change to proto/user/v1/user.proto and run 'nix run'"
          echo "to see the breaking change detection in action!"
        '';
      };
      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;
          config = {
            root = ./.;
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
              files = ["./proto/user/v1/user.proto"];
            };

            # Breaking change detection (disabled for basic testing)
            breaking = {
              enable = false;  # Disabled for testing
              mode = "backward";
              baseReference = "HEAD~1";
              failOnBreaking = true;
              outputFormat = "text";
            };

            languages.go = {
              enable = true;
              outputPath = "gen/go";
              options = ["paths=source_relative"];
              grpc = {
                enable = true;
                options = ["paths=source_relative"];
              };
            };
          };
        };
      };
    });
}
