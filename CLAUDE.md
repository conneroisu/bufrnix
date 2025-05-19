# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bufrnix is a Nix-powered protobuf compiler and code generation tool that provides a declarative, reproducible approach to managing protocol buffers in Nix projects. It combines the power of `protoc` for code generation with linting capabilities from the Buf CLI.

Key features:
- Declarative configuration through Nix
- Support for multiple programming languages (Go, with planned support for Python, Rust)
- Integration with gRPC for service definitions
- Debug capabilities
- Hermetic builds through Nix

## Key Commands

### Development and Testing

```bash
# Enter the development shell
nix develop

# Lint the Nix files (available in devShell)
lint

# Edit the flake.nix (available in devShell)
dx

# Run unit tests
nix flake check
```

### Example Usage

To try the simple example:

```bash
# Navigate to the example directory
cd examples/simple-flake

# Enter the development shell
nix develop

# Run the example
go run main.go
```

### Using bufrnix in Your Project

In your project's `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufr.nix";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, bufrnix, ... }: {
    packages.x86_64-linux.default = bufrnix.lib.mkBufrnixPackage {
      inherit (nixpkgs.legacyPackages.x86_64-linux) lib pkgs;
      config = {
        root = ./.; # Root of your project
        protoc = {
          sourceDirectories = ["./proto"];
          includeDirectories = ["./proto"];
          files = ["./proto/**/*.proto"]; # Or specify individual files
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

After configuring bufrnix in your project:

```bash
# Initialize bufrnix project structure
bufrnix_init

# Generate code from proto files
bufrnix_generate

# Lint your proto files (requires buf CLI)
bufrnix_lint
```

## Architecture

### Core Components

1. **mkBufrnix.nix**
   - Main function that constructs the bufrnix package
   - Processes user configuration and creates appropriate wrappers
   - Handles language-specific plugin integration

2. **bufrnix-options.nix**
   - Defines the configuration schema using Nix module options
   - Includes settings for each language, protoc options, and debug configuration

3. **utils/debug.nix**
   - Provides debugging utilities and logging functions
   - Controls verbosity and error handling

4. **examples/simple-flake/**
   - Demonstrates a complete example with Go and gRPC
   - Shows how to configure bufrnix in a project
   - Includes a working gRPC server and client

### Configuration Options

The configuration schema includes:

1. **Root Directory** (`root`)
   - Specifies the base directory for proto files

2. **Protocol Buffer Options** (`protoc`)
   - `sourceDirectories`: Locations of proto files
   - `includeDirectories`: Import paths for proto files
   - `files`: Specific proto files to process

3. **Language Options** (`languages`)
   - Language-specific settings (Go, with planned Python and Rust support)
   - Output paths
   - Language-specific plugin options
   - gRPC settings

4. **Debug Options** (`debug`)
   - Enable/disable debug mode
   - Control verbosity level
   - Log file configuration

## Workflow

Typical workflow for using bufrnix:

1. Configure bufrnix in your project's `flake.nix`
2. Run `nix run .#<name-of-bufrnix-package-you-configured>`
