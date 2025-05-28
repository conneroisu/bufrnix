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

## Building

```bash
# Generate proto code
nix build .#proto

# Build server and client
nix build .#server
nix build .#client

# Or enter development shell
nix develop

# Run server (in one terminal)
cd Server && dotnet run

# Run client (in another terminal)
cd Client && dotnet run
```

## Generated Code

The generated code includes:
- C# message classes
- gRPC service base classes
- Client and server stubs
- Async/streaming support