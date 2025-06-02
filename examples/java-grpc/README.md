# Java gRPC Example

This example demonstrates Java gRPC code generation using bufrnix with the `grpc/java` generator.

## Features

- gRPC service definitions with multiple RPC patterns
- Java server and client implementations
- All four gRPC communication patterns:
  - Unary RPC
  - Server streaming RPC
  - Client streaming RPC
  - Bidirectional streaming RPC

## Generated Code

The `grpc/java` generator creates:
- Service base classes for server implementation
- Client stub classes (blocking and async)
- Message classes from the base `protocolbuffers/java` generator
- gRPC-specific utilities and interfaces

## Quick Start

1. **Generate the protobuf and gRPC code:**
   ```bash
   nix run .#generate
   ```

2. **Build the project:**
   ```bash
   nix develop
   cd gen/java
   gradle build
   ```

3. **Run the server (in one terminal):**
   ```bash
   gradle runServer
   ```

4. **Run the client (in another terminal):**
   ```bash
   gradle runClient
   ```

## Service Definition

The example includes a `GreeterService` with four different RPC methods:

1. **SayHello** - Simple unary RPC
2. **SayHelloStream** - Server streaming (server sends multiple responses)
3. **SayHelloClientStream** - Client streaming (client sends multiple requests)
4. **SayHelloBidirectional** - Bidirectional streaming (both sides stream)

## Generated Files

After running `nix run .#generate`, you'll find:
- `gen/java/com/example/grpc/v1/` - Generated message classes
- `gen/java/com/example/grpc/v1/GreeterServiceGrpc.java` - gRPC service classes
- `gen/java/build.gradle` - Build file with gRPC dependencies
- `gen/java/pom.xml` - Maven alternative with gRPC dependencies

## gRPC Java Features

This example showcases:
- Type-safe service definitions
- Multiple stub types (blocking, async, future)
- Streaming support for all patterns
- Error handling and status codes
- Channel management and lifecycle
- Service implementation base classes

## Dependencies

The generated build files include:
- `com.google.protobuf:protobuf-java` - Protocol Buffers runtime
- `io.grpc:grpc-stub` - gRPC client stubs
- `io.grpc:grpc-protobuf` - gRPC protobuf integration
- `io.grpc:grpc-netty-shaded` - gRPC transport implementation
- `javax.annotation:javax.annotation-api` - Java annotations