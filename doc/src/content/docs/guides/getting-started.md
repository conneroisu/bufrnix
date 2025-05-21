---
title: Getting Started with Bufrnix
description: Learn how to set up Bufrnix and generate your first Protocol Buffer code.
---

# Getting Started with Bufrnix

Bufrnix makes it easy to integrate Protocol Buffers into your Nix-based projects. This guide will walk you through setting up Bufrnix and generating code for your first Protocol Buffer definitions.

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- Basic familiarity with Protocol Buffers
- A project with `.proto` files

## Installation

Add Bufrnix to your project's `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufrnix";
    # If you want to pin nixpkgs to the same version as bufrnix
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, bufrnix, ... }: {
    # Your outputs here
  };
}
```

## Basic Configuration

Add Bufrnix configuration to your flake outputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, bufrnix, ... }: {
    # Basic configuration
    bufrnix = {
      root = "./proto"; # Root directory for your proto files

      # Example Go configuration
      go = {
        enable = true;
        out = "gen/go"; # Output directory relative to root

        # Enable gRPC support
        grpc = {
          enable = true;
        };
      };
    };
  };
}
```

## Directory Structure

Organize your Protocol Buffer files following this recommended structure:

```
project/
├── flake.nix
├── proto/
│   ├── example/
│   │   └── v1/
│   │       └── example.proto
│   └── another/
│       └── v1/
│           └── service.proto
├── gen/
│   ├── go/
│   ├── js/
│   └── ...
└── ...
```

## Creating Your First Proto File

Create a simple proto file at `proto/example/v1/example.proto`:

```protobuf
syntax = "proto3";

package example.v1;

option go_package = "example/v1;examplev1";

// Simple greeting service
service GreetingService {
  // Sends a greeting
  rpc SayHello(HelloRequest) returns (HelloResponse);
}

// The request message containing the user's name
message HelloRequest {
  string name = 1;
}

// The response message containing the greeting
message HelloResponse {
  string message = 1;
}
```

## Generating Code

Generate code from your proto files using:

```bash
nix run .#bufrnix generate
```

This will process all your Protocol Buffer definitions according to your Bufrnix configuration and output the generated code to the specified directories.

## Multi-language Support

Bufrnix supports multiple languages. Here's an example configuration for generating code for multiple languages:

```nix
bufrnix = {
  root = "./proto";

  # Go configuration
  go = {
    enable = true;
    out = "gen/go";
    grpc.enable = true;
  };

  # JavaScript configuration
  js = {
    enable = true;
    out = "gen/js";
    grpcWeb.enable = true;
  };

  # Dart configuration
  dart = {
    enable = true;
    out = "gen/dart";
    grpc.enable = true;
  };
};
```

## Next Steps

Now that you have Bufrnix set up and generating code:

- Check out the [Configuration Options](/reference/configuration/) to customize code generation
- Learn about [Language Support](/reference/languages/) to see all available languages and plugins
- Explore the [Examples](/guides/examples/) to see how to use generated code in different languages