---
title: Example Projects
description: Learn from pre-built examples that demonstrate how to use Bufrnix in real projects.
---

Bufrnix includes several example projects that demonstrate how to use Protocol Buffers with different languages and frameworks. These examples are complete, working projects that you can use as starting points for your own applications.

## Simple Go gRPC Example

A basic example demonstrating Go gRPC server and client communication.

### Features

- Simple gRPC server and client implementation
- User service with create and get operations
- In-memory storage for demonstration purposes
- Error handling and validation

### Source Code

Check out the [simple-flake example](https://github.com/conneroisu/bufrnix/tree/main/examples/simple-flake) on GitHub.

### Running the Example

```bash
# Navigate to the example directory
cd examples/simple-flake

# Generate the proto code
nix run .#packages.x86_64-linux.bufrnix generate

# Run the example
go run main.go
```

## JavaScript/TypeScript Example

Demonstrates using Protocol Buffers with Node.js and TypeScript.

### Features

- TypeScript support with type definitions
- Modern ES modules
- Simple client implementation
- Integration with npm packages

### Source Code

Check out the [js-example](https://github.com/conneroisu/bufrnix/tree/main/examples/js-example) on GitHub.

### Running the Example

```bash
# Navigate to the example directory
cd examples/js-example

# Generate the proto code
nix develop -c bufrnix generate

# Install dependencies
npm install

# Run the example
npm start
```

## Dart Example

Shows how to use Protocol Buffers with Dart and gRPC for Flutter or server applications.

### Features

- Dart class generation for Protocol Buffers
- gRPC client implementation
- Compatible with Flutter applications
- Demo of async/await usage with gRPC

### Source Code

Check out the [dart-example](https://github.com/conneroisu/bufrnix/tree/main/examples/dart-example) on GitHub.

### Running the Example

```bash
# Navigate to the example directory
cd examples/dart-example

# Generate the proto code
nix develop -c bufrnix generate

# Run the example
dart lib/main.dart
```

## PHP Twirp Example

Demonstrates using Protocol Buffers with PHP and the Twirp RPC framework.

### Features

- PHP class generation for Protocol Buffers
- Twirp HTTP server and client
- Composer integration
- Simple API implementation

### Source Code

Check out the [php-twirp example](https://github.com/conneroisu/bufrnix/tree/main/examples/php-twirp) on GitHub.

### Running the Example

```bash
# Navigate to the example directory
cd examples/php-twirp

# Generate the proto code
nix develop -c bufrnix generate

# Install dependencies
composer install

# Run the example (implementation may vary)
php -S localhost:8080 -t public
```

## Creating Your Own Example

To create your own example:

1. Set up a new directory with a `flake.nix` file
2. Add Bufrnix as an input
3. Configure Bufrnix for your target languages
4. Create your `.proto` files in the appropriate directory
5. Run `nix develop -c bufrnix generate` to generate code
6. Implement your application using the generated code

You can use any of the existing examples as a starting point for your own project.

## C# Basic Example

Demonstrates basic Protocol Buffers usage with C# and .NET.

### Features

- C# class generation for Protocol Buffers
- Binary and JSON serialization
- Nested messages and enums
- Generated .csproj file for easy integration

### Source Code

Check out the [csharp-basic](https://github.com/conneroisu/bufrnix/tree/main/examples/csharp-basic) on GitHub.

### Running the Example

```bash
# Navigate to the example directory
cd examples/csharp-basic

# Generate the proto code
nix build .#proto
./result/bin/bufrnix

# Build and run the example
nix run
```

## C# gRPC Example

Shows how to build gRPC services with C# and ASP.NET Core.

### Features

- gRPC service implementation with ASP.NET Core
- Client console application
- Unary and streaming RPC examples
- Modern .NET 8.0 integration

### Source Code

Check out the [csharp-grpc](https://github.com/conneroisu/bufrnix/tree/main/examples/csharp-grpc) on GitHub.

### Running the Example

```bash
# Navigate to the example directory
cd examples/csharp-grpc

# Generate the proto code
nix build .#proto
./result/bin/bufrnix

# Run the server (in one terminal)
nix run .#server

# Run the client (in another terminal)
nix run .#client
```

## Kotlin Basic Example

Demonstrates basic Protocol Buffers usage with Kotlin.

### Features

- Kotlin DSL builders for message creation
- Immutable message updates with `copy`
- Type-safe builders and null safety
- Generated Gradle build file

### Source Code

Check out the [kotlin-basic](https://github.com/conneroisu/bufrnix/tree/main/examples/kotlin-basic) on GitHub.

### Running the Example

```bash
# Navigate to the example directory
cd examples/kotlin-basic

# Generate the proto code
nix build .#proto
./result/bin/bufrnix

# Build and run with Gradle
cd gen/kotlin
gradle run
```

## Kotlin gRPC Example

Shows how to build gRPC services with Kotlin coroutines.

### Features

- Coroutine-based gRPC services
- Flow-based streaming APIs
- Unary and streaming RPC examples
- Modern Kotlin idioms

### Source Code

Check out the [kotlin-grpc](https://github.com/conneroisu/bufrnix/tree/main/examples/kotlin-grpc) on GitHub.

### Running the Example

```bash
# Navigate to the example directory
cd examples/kotlin-grpc

# Generate the proto code
nix build .#proto
./result/bin/bufrnix

# Run the server (in one terminal)
cd gen/kotlin && gradle runServer

# Run the client (in another terminal)
cd gen/kotlin && gradle runClient
```

## Swift Example

Demonstrates using Protocol Buffers with Swift for iOS, macOS, and server applications.

### Features

- Swift struct generation with Codable support
- Type-safe Protocol Buffer messages
- SwiftProtobuf integration
- Compatible with SwiftPM and Xcode projects

### Source Code

Check out the [swift-example](https://github.com/conneroisu/bufrnix/tree/main/examples/swift-example) on GitHub.

### Running the Example

```bash
# Navigate to the example directory
cd examples/swift-example

# Generate the proto code
nix develop -c bufrnix_init && bufrnix

# Build and run the example
swift build
swift run
```

## Additional Resources

- [Simple-flake README](https://github.com/conneroisu/bufrnix/blob/main/examples/simple-flake/README.md) - More details on the Go example
- [JS Example README](https://github.com/conneroisu/bufrnix/blob/main/examples/js-example/README.md) - JavaScript integration details
- [Dart Example README](https://github.com/conneroisu/bufrnix/blob/main/examples/dart-example/README.md) - Dart and Flutter integration
- [PHP Twirp README](https://github.com/conneroisu/bufrnix/blob/main/examples/php-twirp/README.md) - PHP and Twirp integration
- [C# Basic README](https://github.com/conneroisu/bufrnix/blob/main/examples/csharp-basic/README.md) - C# and .NET integration
- [C# gRPC README](https://github.com/conneroisu/bufrnix/blob/main/examples/csharp-grpc/README.md) - C# gRPC with ASP.NET Core
- [Kotlin Basic README](https://github.com/conneroisu/bufrnix/blob/main/examples/kotlin-basic/README.md) - Kotlin with DSL builders
- [Kotlin gRPC README](https://github.com/conneroisu/bufrnix/blob/main/examples/kotlin-grpc/README.md) - Kotlin gRPC with coroutines
- [Swift Example README](https://github.com/conneroisu/bufrnix/blob/main/examples/swift-example/README.md) - Swift and SwiftProtobuf integration
