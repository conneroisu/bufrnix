---
title: Getting Started with Bufrnix
description: Learn how to set up Bufrnix and generate your first Protocol Buffer code.
---

# Getting Started with Bufrnix

Bufrnix makes it easy to integrate Protocol Buffers into your Nix-based projects with declarative configuration and reproducible builds. This guide will walk you through setting up Bufrnix and generating code for your first Protocol Buffer definitions.

## Prerequisites

- [Nix](https://nixos.org/download.html) with [flakes enabled](https://nixos.wiki/wiki/Flakes)
- Basic familiarity with [Protocol Buffers](https://developers.google.com/protocol-buffers)
- A project directory where you want to add protobuf code generation

## Quick Start

### 1. Create a Flake Configuration

Create a `flake.nix` file in your project root:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufr.nix";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, bufrnix, ... }:
  let
    system = "x86_64-linux";  # Adjust for your system
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.default = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib;
      inherit pkgs;
      config = {
        root = ./.;
        protoc = {
          files = ["./proto/example/v1/example.proto"];
        };
        languages.go = {
          enable = true;
          outputPath = "gen/go";
          grpc.enable = true;
        };
      };
    };
  };
}
```

### 2. Create Your Proto Files

Create a directory structure for your Protocol Buffer definitions:

```
project/
├── flake.nix
├── proto/
│   └── example/
│       └── v1/
│           └── example.proto
└── gen/           # Generated code will appear here
    └── go/
```

Add your first proto file at `proto/example/v1/example.proto`:

```protobuf
syntax = "proto3";

package example.v1;

option go_package = "github.com/yourorg/yourproject/gen/go/example/v1;examplev1";

// Simple greeting service
service GreetingService {
  // Sends a greeting
  rpc SayHello(HelloRequest) returns (HelloResponse);

  // Sends multiple greetings
  rpc SayHelloStream(HelloRequest) returns (stream HelloResponse);
}

// The request message containing the user's name
message HelloRequest {
  string name = 1;
  optional string greeting_type = 2;
}

// The response message containing the greeting
message HelloResponse {
  string message = 1;
  int64 timestamp = 2;
}
```

### 3. Generate Code

Run the code generation:

```bash
nix build
```

This will:

1. Validate your proto files
2. Generate Go protobuf messages in `gen/go/example/v1/example.pb.go`
3. Generate Go gRPC service definitions in `gen/go/example/v1/example_grpc.pb.go`

### 4. Use Generated Code

The generated Go code can be used like this:

```go
package main

import (
    "context"
    "log"
    "net"
    "time"

    "google.golang.org/grpc"
    examplev1 "github.com/yourorg/yourproject/gen/go/example/v1"
)

// Server implementation
type server struct {
    examplev1.UnimplementedGreetingServiceServer
}

func (s *server) SayHello(ctx context.Context, req *examplev1.HelloRequest) (*examplev1.HelloResponse, error) {
    greeting := "Hello"
    if req.GreetingType != nil {
        greeting = *req.GreetingType
    }

    return &examplev1.HelloResponse{
        Message:   greeting + ", " + req.Name + "!",
        Timestamp: time.Now().Unix(),
    }, nil
}

func main() {
    lis, err := net.Listen("tcp", ":50051")
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }

    s := grpc.NewServer()
    examplev1.RegisterGreetingServiceServer(s, &server{})

    log.Println("Server listening at :50051")
    if err := s.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
```

## Multi-Language Support

Bufrnix supports generating code for multiple languages simultaneously. Here's an extended configuration:

```nix
config = {
  root = ./.;
  protoc = {
    sourceDirectories = ["./proto"];
    includeDirectories = ["./proto"];
    files = [
      "./proto/example/v1/example.proto"
      "./proto/user/v1/user.proto"
    ];
  };

  # Go with full ecosystem
  languages.go = {
    enable = true;
    outputPath = "gen/go";
    options = ["paths=source_relative"];
    grpc.enable = true;
    gateway.enable = true;      # HTTP/JSON gateway
    validate.enable = true;     # Message validation
    connect.enable = true;      # Modern Connect protocol
  };

  # Dart for Flutter apps
  languages.dart = {
    enable = true;
    outputPath = "lib/proto";
    packageName = "my_app_proto";
    grpc.enable = true;
  };

  # JavaScript/TypeScript for web
  languages.js = {
    enable = true;
    outputPath = "src/proto";
    packageName = "my-proto";
    es.enable = true;           # Modern ES modules
    connect.enable = true;      # Connect-ES
    grpcWeb.enable = true;      # Browser gRPC
  };

  # PHP for web services
  languages.php = {
    enable = true;
    outputPath = "gen/php";
    namespace = "MyApp\\Proto";
    twirp.enable = true;
  };
};
```

## Development Environment

### Using Nix Development Shell

Create a development environment with all necessary tools:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufr.nix";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, bufrnix, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # Code generation package
    packages.default = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib pkgs;
      config = { /* your config */ };
    };

    # Development shell with language runtimes
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        # Language runtimes for your generated code
        go
        dart
        nodejs
        php

        # Protocol Buffer tools
        protobuf
        protoc-gen-go
        protoc-gen-go-grpc

        # Development tools
        buf  # Modern protobuf linter and build tool
        grpcurl  # Command-line gRPC client
      ];
    };
  };
}
```

Enter the development environment:

```bash
nix develop
```

### Development Workflow

```bash
# Generate code from proto files
nix build

# Enter development shell with all tools
nix develop

# After making changes to .proto files, regenerate code
nix build

# Lint proto files (if buf is in your devShell)
buf lint

# Format proto files
buf format --write

# Test gRPC services (after running your generated server)
grpcurl -plaintext localhost:50051 list

# For the documentation site only:
cd doc && bun run dev  # Live reloading at http://localhost:4321
```

## Configuration Patterns

### Basic Single-Language Setup

For simple Go-only projects:

```nix
config = {
  root = ./.;
  protoc.files = ["./proto/**/*.proto"];
  languages.go = {
    enable = true;
    outputPath = "internal/proto";
    grpc.enable = true;
  };
};
```

### Advanced Multi-Service Setup

For microservices architectures:

```nix
config = {
  root = ./.;
  protoc = {
    sourceDirectories = ["./proto"];
    includeDirectories = [
      "./proto"
      "${pkgs.protobuf}/include"  # Well-known types
    ];
  };

  languages.go = {
    enable = true;
    outputPath = "gen/go";
    packagePrefix = "github.com/myorg/myproject";
    grpc.enable = true;
    gateway.enable = true;
    validate.enable = true;
  };

  debug = {
    enable = true;  # Enable for troubleshooting
    verbosity = 2;
  };
};
```

### Client-Server Projects

For projects with both client and server code:

```nix
{
  packages = {
    # Server-side code with full gRPC
    server = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib pkgs;
      config = {
        languages.go = {
          enable = true;
          grpc.enable = true;
          gateway.enable = true;
        };
      };
    };

    # Client-side code for web
    client = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib pkgs;
      config = {
        languages.js = {
          enable = true;
          es.enable = true;
          grpcWeb.enable = true;
        };
      };
    };
  };
}
```

## Working with Examples

Bufrnix includes several complete examples you can study and modify:

```bash
# Clone the repository to explore examples
git clone https://github.com/conneroisu/bufr.nix.git
cd bufr.nix

# Try the simple Go example
cd examples/simple-flake
nix develop
go run main.go

# Try the comprehensive Dart example
cd ../dart-example
nix develop
dart pub get
dart run lib/main.dart

# Try the JavaScript example
cd ../js-example
nix develop
npm install && npm run build
```

## Next Steps

Now that you have Bufrnix generating code:

1. **Explore Language Features**: Check the [Language Support](/reference/languages/) guide for language-specific options
2. **Advanced Configuration**: See [Configuration Reference](/reference/configuration/) for all available options
3. **Integration Patterns**: Study the [Examples](/guides/examples/) for real-world usage patterns
4. **Troubleshooting**: Visit [Troubleshooting](/guides/troubleshooting/) if you encounter issues
5. **Contributing**: See [Contributing](/guides/contributing/) to add support for new languages or features

## Common First-Time Issues

### Proto File Not Found

```
Error: proto file not found: ./proto/example/v1/example.proto
```

**Solution**: Ensure the file path in `protoc.files` matches your actual file location.

### Import Errors

```
Error: Import "google/protobuf/timestamp.proto" was not found
```

**Solution**: Add well-known types to your include directories:

```nix
protoc.includeDirectories = [
  "./proto"
  "${pkgs.protobuf}/include"
];
```

### Generated Code Import Issues

**Solution**: Check that your `go_package` option matches your actual Go module structure, and ensure generated code is within your Go module.

For more detailed troubleshooting, see the [Troubleshooting Guide](/guides/troubleshooting/).
