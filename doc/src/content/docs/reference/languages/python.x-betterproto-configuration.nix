{
  description = "Python with betterproto example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufrnix = {
      url = "github:conneroisu/bufrnix";
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

      bufrnixConfig = bufrnix.lib.mkBufrnix {
        inherit pkgs;
        config = {
          root = "./proto";

          # Python with betterproto for modern dataclasses
          languages.python = {
            enable = true;
            outputPath = "proto/gen/python";

            # Per-language file control (new feature)
            # files = [
            #   "./proto/common/v1/types.proto"
            #   "./proto/ml/v1/training_service.proto"
            # ];
            # additionalFiles = [
            #   "./proto/google/cloud/storage/v1/storage.proto"
            #   "./proto/third_party/tensorflow/serving/apis/model.proto"
            # ];

            # Use betterproto instead of standard protobuf
            betterproto = {
              enable = true;
            };
          };
        };
      };
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python3
          python3Packages.betterproto
          python3Packages.grpclib # betterproto uses grpclib instead of grpcio
          protobuf
        ];

        shellHook = ''
          echo "Python Betterproto Example"
          echo "========================="
          echo "Commands:"
          echo "  bufrnix_init - Initialize project"
          echo "  bufrnix - Generate betterproto code"
          echo "  python test_betterproto.py - Run test"
          echo ""
          echo "Note: Betterproto generates modern Python dataclasses"
          echo "      with async support and cleaner API"
          echo ""
          ${bufrnixConfig.shellHook}
        '';
      };
    });
}
