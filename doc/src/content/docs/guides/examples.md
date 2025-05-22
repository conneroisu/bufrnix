---
title: Example Projects
description: Learn from pre-built examples that demonstrate how to use Bufrnix in real projects.
---

# Example Projects

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

## Additional Resources

- [Simple-flake README](https://github.com/conneroisu/bufrnix/blob/main/examples/simple-flake/README.md) - More details on the Go example
- [JS Example README](https://github.com/conneroisu/bufrnix/blob/main/examples/js-example/README.md) - JavaScript integration details
- [Dart Example README](https://github.com/conneroisu/bufrnix/blob/main/examples/dart-example/README.md) - Dart and Flutter integration
- [PHP Twirp README](https://github.com/conneroisu/bufrnix/blob/main/examples/php-twirp/README.md) - PHP and Twirp integration
