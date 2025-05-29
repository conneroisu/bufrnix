---
title: Getting Started with Bufrnix
description: Learn how to set up Bufrnix and generate your first Protocol Buffer code with comprehensive examples and troubleshooting.
---

# Getting Started with Bufrnix

Bufrnix makes it easy to integrate Protocol Buffers into your Nix-based projects with declarative configuration and reproducible builds. This comprehensive guide will walk you through setting up Bufrnix, generating code for your first Protocol Buffer definitions, and avoiding common pitfalls.

## Why Choose Bufrnix?

Before diving into setup, it's worth understanding why Bufrnix exists and when it's the right choice for your project:

**🌐 Works Anywhere**: Unlike remote plugin systems, Bufrnix runs completely offline. Perfect for corporate firewalls, air-gapped environments, or unreliable internet connections. No more `context deadline exceeded` errors or geographic latency.

**🔒 Keeps Schemas Private**: All processing happens locally - your proprietary API definitions never leave your environment. Essential for regulated industries (SOX, HIPAA, FedRAMP) and protecting competitive advantages.

**⚡ Blazing Fast**: Up to 60x faster than remote alternatives. No network latency, no rate limiting, no timeouts. Parallel execution across multiple languages and plugins.

**🎯 Truly Reproducible**: Same inputs = identical outputs, always. Cryptographic hashes ensure supply chain integrity across all environments. Content-addressed storage prevents version drift.

**🔧 No Technical Limits**: Break free from 64KB response size constraints, enable plugin chaining, file system access, and custom multi-stage workflows that remote systems can't support.

**💰 Cost Effective**: Access the full community plugin ecosystem without Pro/Enterprise subscriptions. Develop custom plugins without approval bottlenecks.

### Real-World Scenarios

**Choose Bufrnix when you need:**
- Offline development in corporate or air-gapped environments
- Processing sensitive schemas that can't leave your infrastructure  
- High-performance builds with complex multi-language generation
- Custom plugins or community plugins not in Buf's approved registry
- Compliance with regulations requiring local data processing
- Supply chain security with cryptographic dependency verification

**Buf's remote plugins work well for:**
- Quick experimentation and getting started
- Simple, single-language projects with standard plugins
- Teams comfortable with external schema processing
- Workflows that fit within remote plugin technical limitations

Many teams use **both tools together**: Buf for schema management and validation, Bufrnix for production code generation.

**Ready to get started?** Let's build your first Bufrnix project.

## Prerequisites

- [Nix](https://nixos.org/download.html) with [flakes enabled](https://nixos.wiki/wiki/Flakes)
- Basic familiarity with [Protocol Buffers](https://developers.google.com/protocol-buffers)
- A project directory where you want to add protobuf code generation

### Enabling Nix Flakes

If you haven't enabled flakes yet, add this to your Nix configuration:

```bash
# For NixOS, add to /etc/nixos/configuration.nix:
nix.settings.experimental-features = [ "nix-command" "flakes" ];

# For non-NixOS systems, add to ~/.config/nix/nix.conf:
experimental-features = nix-command flakes
```

## Quick Start

### 1. Create a Flake Configuration

Create a `flake.nix` file in your project root:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, bufrnix, ... }:
  let
    system = "x86_64-linux";  # Adjust for your system: x86_64-darwin, aarch64-linux, aarch64-darwin
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

    # Development shell with all necessary tools
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        go
        protobuf
        buf  # Modern protobuf linter and build tool
        grpcurl  # Command-line gRPC client
      ];
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

// Simple greeting service demonstrating various protobuf features
service GreetingService {
  // Standard unary RPC
  rpc SayHello(HelloRequest) returns (HelloResponse);

  // Server streaming RPC
  rpc SayHelloStream(HelloRequest) returns (stream HelloResponse);

  // Client streaming RPC
  rpc SayManyHellos(stream HelloRequest) returns (HelloResponse);

  // Bidirectional streaming RPC
  rpc SayHelloBidi(stream HelloRequest) returns (stream HelloResponse);
}

// The request message containing the user's name
message HelloRequest {
  string name = 1;
  optional string greeting_type = 2;
  repeated string languages = 3;

  // Nested message example
  UserInfo user_info = 4;
}

// Nested message demonstrating message composition
message UserInfo {
  string email = 1;
  int32 age = 2;
  UserType type = 3;
}

// Enum example
enum UserType {
  USER_TYPE_UNSPECIFIED = 0;
  USER_TYPE_REGULAR = 1;
  USER_TYPE_PREMIUM = 2;
  USER_TYPE_ADMIN = 3;
}

// The response message containing the greeting
message HelloResponse {
  string message = 1;
  int64 timestamp = 2;
  bool success = 3;

  // Using well-known types
  google.protobuf.Duration processing_time = 4;
}
```

### 3. Generate Code

Run the code generation:

```bash
nix build
```

This will:

1. Validate your proto files using `buf` (if enabled)
2. Generate Go protobuf messages in `gen/go/example/v1/example.pb.go`
3. Generate Go gRPC service definitions in `gen/go/example/v1/example_grpc.pb.go`
4. Create any necessary directory structure

### 4. Use Generated Code

The generated Go code can be used like this:

```go
package main

import (
    "context"
    "fmt"
    "log"
    "net"
    "time"

    "google.golang.org/grpc"
    "google.golang.org/protobuf/types/known/durationpb"
    examplev1 "github.com/yourorg/yourproject/gen/go/example/v1"
)

// Server implementation
type server struct {
    examplev1.UnimplementedGreetingServiceServer
}

func (s *server) SayHello(ctx context.Context, req *examplev1.HelloRequest) (*examplev1.HelloResponse, error) {
    start := time.Now()

    greeting := "Hello"
    if req.GreetingType != nil {
        greeting = *req.GreetingType
    }

    // Handle optional user info
    var userSuffix string
    if req.UserInfo != nil {
        userSuffix = fmt.Sprintf(" (User: %s, Type: %s)",
            req.UserInfo.Email,
            req.UserInfo.Type.String())
    }

    // Handle repeated languages field
    langSuffix := ""
    if len(req.Languages) > 0 {
        langSuffix = fmt.Sprintf(" in languages: %v", req.Languages)
    }

    return &examplev1.HelloResponse{
        Message:        greeting + ", " + req.Name + "!" + userSuffix + langSuffix,
        Timestamp:      time.Now().Unix(),
        Success:        true,
        ProcessingTime: durationpb.New(time.Since(start)),
    }, nil
}

func (s *server) SayHelloStream(req *examplev1.HelloRequest, stream examplev1.GreetingService_SayHelloStreamServer) error {
    for i := 0; i < 5; i++ {
        response := &examplev1.HelloResponse{
            Message:   fmt.Sprintf("Stream message %d for %s", i+1, req.Name),
            Timestamp: time.Now().Unix(),
            Success:   true,
        }

        if err := stream.Send(response); err != nil {
            return err
        }

        time.Sleep(1 * time.Second)
    }
    return nil
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
    grpc = {
      enable = true;
      options = ["paths=source_relative"];
    };
    gateway = {
      enable = true;      # HTTP/JSON gateway
      options = ["paths=source_relative"];
    };
    validate = {
      enable = true;     # Message validation
      options = ["lang=go"];
    };
    connect = {
      enable = true;      # Modern Connect protocol
      options = ["paths=source_relative"];
    };
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
    es = {
      enable = true;           # Modern ES modules
      options = ["target=ts"];  # Generate TypeScript
    };
    connect = {
      enable = true;      # Connect-ES
      options = ["target=ts"];
    };
    grpcWeb = {
      enable = true;      # Browser gRPC
      options = ["import_style=typescript" "mode=grpcwebtext"];
    };
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
    bufrnix.url = "github:conneroisu/bufrnix";
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
        php83

        # Protocol Buffer tools
        protobuf
        protoc-gen-go
        protoc-gen-go-grpc

        # Development tools
        buf          # Modern protobuf linter and build tool
        grpcurl      # Command-line gRPC client
        protoc-gen-grpc-web
        protoc-gen-connect-go

        # Optional: language-specific tools
        golangci-lint
        gopls
      ];

      shellHook = ''
        echo "🚀 Bufrnix development environment loaded!"
        echo "Available commands:"
        echo "  nix build     - Generate protobuf code"
        echo "  buf lint      - Lint proto files"
        echo "  buf format    - Format proto files"
        echo "  grpcurl       - Test gRPC services"
      '';
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
grpcurl -plaintext -d '{"name": "World"}' localhost:50051 example.v1.GreetingService/SayHello
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
      "${pkgs.googleapis-common-protos}/share/googleapis-common-protos"  # Google APIs
    ];
  };

  languages.go = {
    enable = true;
    outputPath = "gen/go";
    packagePrefix = "github.com/myorg/myproject";
    grpc = {
      enable = true;
      options = ["require_unimplemented_servers=false"];
    };
    gateway = {
      enable = true;
      options = ["generate_unbound_methods=true"];
    };
    validate = {
      enable = true;
      options = ["lang=go"];
    };
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
        root = ./.;
        protoc.files = ["./proto/**/*.proto"];
        languages.go = {
          enable = true;
          outputPath = "server/proto";
          grpc.enable = true;
          gateway.enable = true;
        };
      };
    };

    # Client-side code for web
    client = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib pkgs;
      config = {
        root = ./.;
        protoc.files = ["./proto/**/*.proto"];
        languages.js = {
          enable = true;
          outputPath = "client/src/proto";
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
git clone https://github.com/conneroisu/bufrnix.git
cd bufrnix

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

# Try the PHP Twirp example
cd ../php-twirp
nix develop
composer install
```

## Common First-Time Issues

### Proto File Not Found

**Error:**

```
Error: proto file not found: ./proto/example/v1/example.proto
```

**Solutions:**

1. Ensure the file path in `protoc.files` matches your actual file location
2. Check that the file exists and has the correct permissions
3. Use relative paths from the `root` directory

### Import Errors

**Error:**

```
Import "google/protobuf/timestamp.proto" was not found
```

**Solution:** Add well-known types to your include directories:

```nix
protoc.includeDirectories = [
  "./proto"
  "${pkgs.protobuf}/include"
];
```

### Generated Code Import Issues

**Error:**

```
package github.com/yourorg/yourproject/gen/go/example/v1 is not in GOROOT or GOPATH
```

**Solutions:**

1. Check that your `go_package` option matches your actual Go module structure
2. Ensure generated code is within your Go module
3. Run `go mod tidy` after generation
4. Verify your `go.mod` file includes the correct module path

### Nix Build Failures

**Error:**

```
error: builder for '/nix/store/...' failed with exit code 1
```

**Troubleshooting steps:**

1. Enable debug mode in your configuration:
   ```nix
   debug = {
     enable = true;
     verbosity = 3;
   };
   ```
2. Check the detailed build log for specific errors
3. Verify all dependencies are correctly specified
4. Ensure your proto files are syntactically correct

### Permission Issues

**Error:**

```
Permission denied: cannot write to gen/go/
```

**Solutions:**

1. Ensure the output directory is writable
2. Check that no files are currently open in editors
3. On macOS, verify that Nix has the necessary permissions

### System Architecture Issues

**Error:**

```
error: a 'x86_64-linux' with features {} is required to build...
```

**Solution:** Ensure your `system` variable matches your actual system:

```nix
let
  # Use the correct system identifier
  # x86_64-linux, x86_64-darwin, aarch64-linux, aarch64-darwin
  system = builtins.currentSystem; # or specify explicitly
```

## Performance Tips

1. **Use specific file lists** instead of globbing for faster builds:

   ```nix
   protoc.files = [
     "./proto/user/v1/user.proto"
     "./proto/product/v1/product.proto"
   ];
   ```

2. **Enable parallel builds** in your Nix configuration:

   ```bash
   # Add to ~/.config/nix/nix.conf
   max-jobs = auto
   ```

3. **Use Nix binary caches** to avoid rebuilding dependencies:
   ```bash
   # Add to ~/.config/nix/nix.conf
   substituters = https://cache.nixos.org https://nix-community.cachix.org
   trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
   ```

## Next Steps

Now that you have Bufrnix generating code:

1. **Explore Language Features**: Check the [Language Support](/reference/languages/) guide for language-specific options
2. **Advanced Configuration**: See [Configuration Reference](/reference/configuration/) for all available options
3. **Integration Patterns**: Study the [Examples](/guides/examples/) for real-world usage patterns
4. **Troubleshooting**: Visit [Troubleshooting](/guides/troubleshooting/) if you encounter issues
5. **Contributing**: See [Contributing](/guides/contributing/) to add support for new languages or features
6. **Best Practices**: Read the [Best Practices](/guides/best-practices/) guide for optimal development workflows

## Getting Help

If you encounter issues not covered in this guide:

1. Check the [troubleshooting guide](/guides/troubleshooting/)
2. Browse the [examples directory](https://github.com/conneroisu/bufrnix/tree/main/examples) for similar use cases
3. Search or create an issue on [GitHub](https://github.com/conneroisu/bufrnix/issues)
4. Join the discussion in the repository's discussion section

Remember that Bufrnix leverages the power of Nix for reproducible builds, so builds that work on one machine should work identically on all machines with the same Nix configuration.
