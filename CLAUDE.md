# bufnrix Development Guidelines

## Build, Test & Lint Commands
- **Enter Dev Environment**: `nix develop`
- **Reload Dev Environment**: `direnv reload`
- **Build Docs**: `nix build .#packages.x86_64-linux.doc`
- **Format Code**: `format` (formats Go with gofmt and golines, Nix with alejandra)
- **Run Tests**: `tests` (all tests with -short flag)
- **Run Unit Tests**: `unit-tests` (all tests)
- **Run Single Test**: `go test -v ./path/to/package -run TestName`
- **Lint**: `lint` (lints Nix) Example: `> lint`

## Code Style Guidelines

## Project Structure
- `/src/modules`: Nix module definitions for protobuf generation
- `/doc/src`: Documentation powered by mdbook
- `/examples`: Example flake configurations each with their own README and directory.

### Modules

Essentially, modules provide:
- Package Dependencies
- protoc arguments
- protoc routines (additional calls to protoc inside of the generated script)

Example:

```nix name="flake.nix"
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bufnrix.url = "github:conneroisu/bufnrix/main";
  };

  outputs = { self, nixpkgs, bufnrix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in 
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              bufnrix.packages.${system}.default
            ];
          };
        }
    );
}
```

## Supported Platforms
- x86_64-linux, i686-linux, x86_64-darwin, aarch64-linux, aarch64-darwin

## Development Environment
- Nix 2.26.3
- direnv

# Bufrnix Developer Documentation Guide - Phase 1 (Weeks 1-2)

During Phase 1, we'll focus on core functionality: creating a basic package structure with minimal Nix configuration, implementing a protoc wrapper for Go, creating a simple initialization script, and building basic debug functionality.

## Table of Contents

1. [Project Vision](#project-vision)
2. [Phase 1 Development Goals](#phase-1-development-goals)
3. [Architecture Overview](#architecture-overview)
4. [Core Components](#core-components)
5. [Implementation Strategy](#implementation-strategy)
6. [Testing Strategy](#testing-strategy)
7. [Development Patterns](#development-patterns)
8. [Next Steps](#next-steps)

## Project Vision

Bufrnix is designed to be a comprehensive, Nix-powered Protobuf development solution that:

- Creates a standalone package with no devShell dependencies
- Uses protoc for all code generation while leveraging Buf CLI for linting
- Provides built-in wrapper commands for common operations
- Creates a hermetic environment for reproducible builds

## Phase 1 Development Goals

1. Basic package structure - Success criteria: Package can be imported in flake.nix
2. Protoc Go wrapper - Success criteria: Go code generation works for simple protos
3. Directory initialization - Success criteria: Running init creates expected directory structure
4. Basic debugging - Success criteria: Debug mode shows detailed command execution

## Architecture Overview

The high-level architecture for Bufrnix consists of:

```plaintext
[flake.nix]
  └──> [bufrnix package]
         └──> [mkBufrnixPackage function]
               ├── Creates a standalone package with protoc, Buf tools and wrappers
               ├── Provides executables for common Protobuf operations
               ├── Configures debug capabilities if enabled
               └── Includes testing, documentation, and CI integration
```

For user projects, the integration will look like:

```plaintext
[Your project's flake.nix]
  └──> [integrations]
         ├── Import bufrnix package directly
         ├── Use as direct dependency in any context (not just devShell)
         └── Can be used as a buildInput, dependency, or standalone tool
```

## Core Components

During Phase 1, we'll develop these key components:

### 1. Basic Package Structure

Create the basic file structure:
```plaintext
/src/lib/
    bufrnix-options.nix    # All Nix module options (languages, debug, etc.)
    mkBufrnix.nix          # Constructs the bufrnix package
    utils/
      debug.nix            # Debug utilities and functions
```

### 2. Protoc Wrapper for Go

Implement Go language support with these configuration options:
```nix
languages = {
  go = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Go code generation";
    };
    
    outputPath = mkOption {
      type = types.str;
      default = "gen/go";
      description = "Output directory for generated Go code";
    };
    
    options = mkOption {
      type = types.listOf types.str;
      default = [ "paths=source_relative" ];
      description = "Options to pass to protoc-gen-go";
    };
    
    packagePrefix = mkOption {
      type = types.str;
      default = "";
      description = "Go package prefix for generated code";
    };
  };
}
```


## Implementation Strategy

The implementation will start with a basic `flake.nix` structure:

```nix
{
  description = "bufrnix: Nix-powered protobuf package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      
      # Create a bufrnix package based on configuration
      mkBufrnixPackage = system: config:
        # Implementation details will go here
    in {
      # Package exports will go here
    };
}
```

## Testing Strategy

The testing strategy for Phase 1 includes:

1. **Unit Testing:**
   - Create a flake and respective simple test proto file with basic definitions
   - Verify correct protoc command generation

2. **Integration Testing:**
   - Build a simple service definition
   - Generate code and compile it

## Development Patterns

### 1. Pure Nix Package Pattern

Create a pure Nix package that is compatible with any Nix workflow, without explicit ties to devShell.

### 2. Command Wrapping Pattern

Implement wrapper commands for common operations:
```bash
# Generate protobuf code using protoc (with all configured plugins)
$ bufrnix generate

# Lint proto files with buf
$ bufrnix lint
```

### 3. Configuration Options Pattern

Define a clear structure for proto configuration:
```nix
protoc = {
  sourceDirectories = mkOption {
    type = types.listOf types.str;
    default = [ "./proto" ];
    description = "Directories containing proto files to compile";
  };
  
  includeDirectories = mkOption {
    type = types.listOf types.str;
    default = [ "./proto" ];
    description = "Directories to include in the include path";
  };
  
  files = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Specific proto files to compile (leave empty to compile all)";
  };
};
```

## Existing Example/Test Project

We have a simple example project that can be used to build out this blueprint. (See [examples/simple-flake](https://github.com/conneroisu/bufrnix/tree/main/examples/simple-flake))

# Tracking Progress

We track progress using the TODO.md file at the root of the project.
