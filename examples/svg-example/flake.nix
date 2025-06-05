{
  description = "SVG diagram generation example with bufrnix";

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

      # Create a custom protoc-gen-d2 package
      # TODO: This should eventually be contributed to nixpkgs
      protoc-gen-d2 = pkgs.buildGoModule rec {
        pname = "protoc-gen-d2";
        version = "unstable-2024-01-01";

        src = pkgs.fetchFromGitHub {
          owner = "mvrilo";
          repo = "protoc-gen-d2";
          rev = "main";
          sha256 = "sha256-oP9oohemj1dvYVePXunPfDw9gaRF4vcbIn8pKy+tp+4=";
        };

        vendorHash = "sha256-befhSI1kYAhWoKcD4eg+ByFGgmOGgMmITHgKkBkZnY8=";

        meta = with pkgs.lib; {
          description = "Protocol buffer plugin for generating D2 diagrams";
          homepage = "https://github.com/mvrilo/protoc-gen-d2";
          license = licenses.mit;
        };
      };
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          protobuf
          protoc-gen-go
          protoc-gen-go-grpc
          protoc-gen-doc
          d2 # D2 runtime for rendering
          # protoc-gen-d2 would be included automatically by bufrnix
        ];
      };

      packages = {
        default = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;
          config = {
            root = ".";
            protoc = {
              sourceDirectories = ["./proto"];
              includeDirectories = ["./proto"];
              files = ["./proto/example/v1/example.proto"];
            };

            # Generate SVG diagrams
            languages.svg = {
              enable = true;
              outputPath = "proto/gen/svg";
              package = protoc-gen-d2;
              options = [];
            };

            # Also generate Go code and HTML docs for comparison
            languages.go = {
              enable = true;
              outputPath = "proto/gen/go";
              grpc.enable = true;
            };

            languages.doc = {
              enable = true;
              outputPath = "proto/gen/doc";
              format = "html";
              outputFile = "index.html";
            };
          };
        };
      };
    });
}
