# C# gRPC Example

This example demonstrates gRPC service implementation with C# and Bufrnix.

## Features

- gRPC service definition (Greeter)
- Unary RPC calls
- Server streaming RPC
- Bidirectional streaming RPC
- ASP.NET Core gRPC server
- .NET gRPC client

## Structure

- `proto/` - Protocol buffer service definitions
- `Server/` - ASP.NET Core gRPC server implementation
- `Client/` - Console client application
- `flake.nix` - Nix flake configuration with Bufrnix

## Quick Start

```bash
# Run the complete demo (server + client automatically)
nix run .#runDemo
```

## Building

```bash
# Generate proto code
nix build .#proto

# Build server and client
nix build .#server
nix build .#client

# Or enter development shell for manual development
nix develop

# Manual execution (run server in one terminal)
cd Server && dotnet run

# Manual execution (run client in another terminal)
cd Client && dotnet run
```

## Commands

- `nix run .#runDemo` - **Recommended**: Run complete demo with server and client
- `nix build .#proto` - Generate protobuf/gRPC code
- `nix build .#server` - Build the server application
- `nix build .#client` - Build the client application
- `nix develop` - Enter development shell for manual work

## Generated Code

The generated code includes:

- C# message classes
- gRPC service base classes
- Client and server stubs
- Async/streaming support
