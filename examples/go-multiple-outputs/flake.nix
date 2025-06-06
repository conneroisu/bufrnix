{
  description = "Go Multiple Output Paths - Demonstrates generating Go protobuf code to multiple locations for microservices";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.url = "path:../..";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    bufrnix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        packages = {
          default = bufrnix.lib.mkBufrnixPackage {
            inherit pkgs;
            config = {
              root = ".";
              protoc = {
                includeDirectories = ["proto"];
                files = [
                  "proto/orders/v1/order.proto"
                  "proto/payments/v1/payment.proto"
                ];
              };

              languages = {
                go = {
                  enable = true;
                  # Generate Go code to multiple microservice directories
                  outputPath = [
                    "gen/go"                      # Main generated code location
                    "services/order/proto"        # Order service proto
                    "services/payment/proto"      # Payment service proto
                    "services/shared/proto"       # Shared across all services
                    "pkg/common/proto"            # Common package for libraries
                  ];
                  grpc = {
                    enable = true;
                    # Generate gRPC to subset of locations for service boundaries
                    outputPath = [
                      "gen/go/grpc"
                      "services/order/proto/grpc"
                      "services/payment/proto/grpc"
                    ];
                  };
                  validate = {
                    enable = true;
                    # Generate validation only where needed
                    outputPath = [
                      "gen/go/validate"
                      "services/shared/proto/validate"
                    ];
                  };
                };
              };
              
              debug = {
                enable = true;
                verbosity = 2;
              };
            };
          };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            protobuf
            protoc-gen-go
            protoc-gen-go-grpc
            buf
          ];
          
          shellHook = ''
            echo "🚀 Go Multiple Output Paths Example"
            echo "=================================="
            echo ""
            echo "This example demonstrates generating Go protobuf code to multiple"
            echo "directories simultaneously - perfect for microservices architectures!"
            echo ""
            echo "Output locations configured:"
            echo "  📦 Main: gen/go, gen/go/grpc, gen/go/validate"
            echo "  🏪 Order Service: services/order/proto, services/order/proto/grpc"
            echo "  💳 Payment Service: services/payment/proto, services/payment/proto/grpc"
            echo "  🤝 Shared: services/shared/proto, services/shared/proto/validate"
            echo "  📚 Common: pkg/common/proto"
            echo ""
            echo "Commands:"
            echo "  nix run     - Generate protobuf code to all locations"
            echo "  nix develop - Enter development environment"
            echo ""
          '';
        };
      }
    );
}