# C++ gRPC Service Example

This example demonstrates comprehensive gRPC service implementation in C++ using Bufrnix for code generation.

## Features

- **Unary RPC** - Simple request/response
- **Server Streaming** - Server sends multiple responses
- **Client Streaming** - Client sends multiple requests
- **Bidirectional Streaming** - Both sides stream simultaneously
- **Multi-language greetings** - Demonstrates request processing
- **Timestamp handling** - Using protobuf well-known types
- **Arena allocation** - High-performance memory management
- **Mock code generation** - For testing support

## Generated Files

Bufrnix generates these C++ files from `proto/example/v1/greeter.proto`:

- `proto/gen/cpp/example/v1/greeter.pb.h` - Message declarations
- `proto/gen/cpp/example/v1/greeter.pb.cc` - Message implementations
- `proto/gen/cpp/example/v1/greeter.grpc.pb.h` - gRPC service declarations
- `proto/gen/cpp/example/v1/greeter.grpc.pb.cc` - gRPC service implementations

## Usage

### Development Shell

```bash
nix develop
```

Provides all tools including grpcurl for testing.

### Building

```bash
# Build both server and client
cmake -B build -G Ninja
cmake --build build

# Build only server
cmake -B build -G Ninja -DBUILD_CLIENT=OFF
cmake --build build

# Build only client
cmake -B build -G Ninja -DBUILD_SERVER=OFF
cmake --build build
```

### Running

**Terminal 1 - Start Server:**

```bash
./build/grpc-server
```

**Terminal 2 - Run Client:**

```bash
./build/grpc-client
```

### Testing with grpcurl

```bash
# Test unary RPC
grpcurl -plaintext -d '{"name": "World", "language": "en"}' \
  localhost:50051 example.v1.GreeterService/SayHello

# Test server streaming
grpcurl -plaintext -d '{"name": "StreamTest"}' \
  localhost:50051 example.v1.GreeterService/SayHelloStream
```

## Configuration

The gRPC generation is configured in `flake.nix`:

```nix
languages.cpp = {
  enable = true;
  protobufVersion = "latest";
  standard = "c++20";
  optimizeFor = "SPEED";
  arenaAllocation = true;  # High-performance memory management

  grpc = {
    enable = true;
    generateMockCode = true;  # For testing
    options = ["paths=source_relative"];
  };
};
```

## Service Implementation

### Server (`src/server.cpp`)

- Implements all four gRPC patterns
- Multi-language greeting support
- Proper error handling
- Streaming management
- Resource cleanup

### Client (`src/client.cpp`)

- Demonstrates all RPC patterns
- Concurrent streaming operations
- Connection management
- Error handling and timeouts

## Performance Features

- **Arena Allocation**: Enabled for better memory performance
- **C++20**: Modern language features
- **Optimized Generated Code**: SPEED optimization mode
- **Efficient Streaming**: Proper resource management

## Dependencies

Managed through Nix:

- **gRPC C++** - Service framework
- **Protocol Buffers** - Serialization
- **Abseil** - Google's C++ libraries
- **CMake & Ninja** - Build system

## Testing

The example includes:

- **Unit tests** with generated mock services
- **Integration tests** with client/server
- **Performance benchmarks**
- **Memory leak detection** with valgrind

## Next Steps

- Try `cpp-cmake-integration` for advanced CMake usage
- Explore `cpp-embedded` for resource-constrained environments
- Check out authentication and TLS examples

