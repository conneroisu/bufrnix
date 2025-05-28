# Kotlin gRPC Example

This example demonstrates gRPC service implementation with Kotlin and Bufrnix.

## Features

- Coroutine-based gRPC services
- Unary RPC calls
- Server streaming RPC
- Client streaming RPC
- Bidirectional streaming RPC
- Kotlin DSL for message creation
- Flow-based streaming APIs

## Structure

- `proto/` - Protocol buffer service definitions
- `src/main/kotlin/server/` - gRPC server implementation
- `src/main/kotlin/client/` - gRPC client implementation
- `flake.nix` - Nix flake configuration with Bufrnix

## Building

```bash
# Generate proto code
nix build .#proto

# The generated code will be in:
# - gen/kotlin/java/ - Java protobuf and gRPC stubs
# - gen/kotlin/kotlin/ - Kotlin coroutine-based stubs
# - gen/kotlin/build.gradle.kts - Gradle build file

# Enter development shell
nix develop

# Build with Gradle
cd gen/kotlin
gradle build

# Run server (in one terminal)
gradle runServer

# Run client (in another terminal)
gradle runClient
```

## Generated Code

The Kotlin gRPC plugin generates:
- Coroutine-based service base classes
- Flow-based streaming APIs
- Suspend functions for unary calls
- Type-safe stub classes

## Kotlin gRPC Features

```kotlin
// Coroutine-based service implementation
class GreeterService : GreeterGrpcKt.GreeterCoroutineImplBase() {
    override suspend fun sayHello(request: HelloRequest): HelloReply {
        // Suspend function for async handling
        delay(100)
        return helloReply { 
            message = "Hello ${request.name}!"
        }
    }
    
    override fun sayHelloStream(request: HelloRequest): Flow<HelloReply> = flow {
        // Flow-based streaming
        repeat(5) {
            emit(helloReply { message = "Hello #$it" })
            delay(1000)
        }
    }
}
```

## Dependencies

- Kotlin 2.1.20
- gRPC Kotlin 1.4.2
- Kotlinx Coroutines 1.8.0
- Protobuf 4.28.2