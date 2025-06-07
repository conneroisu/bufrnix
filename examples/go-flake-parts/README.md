# Go Flake-Parts Example

This example demonstrates how to use Bufrnix with [flake-parts](https://github.com/hercules-ci/flake-parts), a popular framework for organizing Nix flakes in a modular way.

## Features

- **Flake-parts integration**: Uses the `flake-parts.lib.mkFlake` function for better flake organization
- **Multi-system support**: Configured for all common platforms (x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin)
- **gRPC service**: Demonstrates a simple UserService with protobuf message generation
- **Clean architecture**: Separates concerns using flake-parts' `perSystem` configuration

## Quick Start

```bash
# Generate protobuf code
nix run

# Enter development environment
nix develop

# Build and run the Go application
go run main.go
```

## Flake-Parts Benefits

Flake-parts provides several advantages over traditional flake configurations:

1. **Modularity**: Better organization of flake outputs
2. **System abstraction**: Automatic handling of different systems
3. **Composability**: Easy to extend and modify configurations
4. **Type safety**: Better error messages and validation

## Generated Code

The example generates:
- `proto/gen/go/example/v1/service.pb.go` - Protocol buffer messages
- `proto/gen/go/example/v1/service_grpc.pb.go` - gRPC service definitions

## Configuration Highlights

The flake uses `perSystem` to define outputs that are automatically available for all supported systems:

```nix
perSystem = { config, self', inputs', pkgs, system, ... }: {
  devShells.default = pkgs.mkShell { ... };
  packages.default = inputs.bufrnix.lib.mkBufrnixPackage { ... };
};
```

This is more maintainable than manually handling each system in a traditional flake.