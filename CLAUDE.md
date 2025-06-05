# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Bufrnix** is a Nix-powered Protocol Buffers code generation framework that provides declarative, reproducible protobuf compilation for multiple programming languages. The project eliminates dependency hell and network requirements by leveraging Nix's deterministic package management.

### Core Philosophy
- **Local-first**: All code generation happens locally without network dependencies
- **Reproducible**: Same inputs produce identical outputs across all environments
- **Multi-language**: Support for Go, Dart, JavaScript/TypeScript, PHP, Swift, and more
- **Developer-friendly**: Zero setup with comprehensive tooling included

## Key Commands

### Development and Building

```bash
# Enter development environment
nix develop

# Format all code files (Nix, Markdown, TypeScript, YAML)
nix fmt

# Run linting for Nix files (statix + deadnix)
lint

# Edit flake.nix in development environment
dx

# Check all examples work correctly
./check-examples.sh
```

### Documentation Development

```bash
# Navigate to documentation directory
cd doc

# Enter documentation development environment
nix develop

# Install dependencies
bun install

# Start development server (http://localhost:4321)
bun run dev

# Build static documentation site
bun run build
```

### Example Testing

```bash
# Test a specific example
cd examples/go-advanced
nix develop
nix run

# Test JavaScript example
cd examples/js-example
nix develop
npm install && npm run build && npm start

# Test PHP example
cd examples/php-twirp
nix develop
composer install
php -S localhost:8080 -t src/
```

## Architecture

### Core Components

1. **Language Modules (`src/languages/`)**
   - Individual Nix modules for each supported language
   - Plugin configurations for protoc code generation
   - Language-specific options and package management
   - Examples: `go/`, `dart/`, `js/`, `php/`, `swift/`

2. **Core Library (`src/lib/`)**
   - `mkBufrnix.nix`: Main function for creating Bufrnix packages
   - `bufrnix-options.nix`: Configuration schema and validation
   - `utils/`: Helper functions for debugging and utilities

3. **Examples (`examples/`)**
   - Complete working examples for each language
   - Demonstrates best practices and common patterns
   - Includes basic, gRPC, advanced, and multi-project scenarios

4. **Documentation (`doc/`)**
   - Astro-based documentation site
   - Comprehensive guides and API reference
   - Language-specific tutorials and troubleshooting

### Data Flow

1. **Configuration**: User defines protobuf files and language targets in `flake.nix`
2. **Validation**: Configuration is validated against the schema in `bufrnix-options.nix`
3. **Code Generation**: `mkBufrnix.nix` orchestrates protoc with appropriate plugins
4. **Output**: Generated code is placed in specified output directories

## Language Support

### Supported Languages

| Language | Base Plugin | Additional Plugins | Status |
|----------|-------------|-------------------|---------|
| **Go** | `protoc-gen-go` | gRPC, Connect, Gateway, Validate | ✅ Full |
| **Dart** | `protoc-gen-dart` | gRPC | ✅ Full |
| **JavaScript/TypeScript** | `protoc-gen-js` | ES modules, Connect-ES, gRPC-Web, Twirp | ✅ Full |
| **PHP** | `protoc-gen-php` | Twirp, Async, Laravel, Symfony | ✅ Full |
| **Swift** | `protoc-gen-swift` | - | ✅ Full |
| **Java** | `protoc-gen-java` | gRPC, Protovalidate | ✅ Full |
| **C/C++** | `protoc-gen-cpp` | gRPC, nanopb | ✅ Basic |
| **Kotlin** | `protoc-gen-kotlin` | gRPC, Connect | ✅ Basic |
| **C#** | `protoc-gen-csharp` | gRPC | ✅ Basic |
| **Python** | `protoc-gen-python` | gRPC, mypy, betterproto | ✅ Basic |
| **Scala** | `protoc-gen-scala` | gRPC | ✅ Basic |

### Adding New Language Support

1. Create new module in `src/languages/[language]/`
2. Define configuration options in `src/lib/bufrnix-options.nix`
3. Create example project in `examples/[language]-[type]/`
4. Update documentation in `doc/src/content/docs/reference/languages/`

## Configuration Reference

### Basic Configuration Structure

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufr.nix";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, bufrnix, ... }: {
    packages.default = bufrnix.lib.mkBufrnixPackage {
      inherit (nixpkgs.legacyPackages.x86_64-linux) lib pkgs;
      config = {
        root = ./.;
        protoc = {
          sourceDirectories = ["./proto"];
          includeDirectories = ["./proto"];
          files = ["./proto/example/v1/example.proto"];
        };
        languages = {
          # Language configurations here
        };
      };
    };
  };
}
```

### Common Configuration Patterns

```nix
# Multi-language generation
languages = {
  go = {
    enable = true;
    outputPath = "gen/go";
    grpc.enable = true;
    validate.enable = true;
  };
  
  js = {
    enable = true;
    outputPath = "src/proto";
    es.enable = true;
    connect.enable = true;
  };
  
  dart = {
    enable = true;
    outputPath = "lib/proto";
    grpc.enable = true;
  };
};

# Debug configuration
debug = {
  enable = true;
  verbosity = 2;
  logFile = "bufrnix-debug.log";
};
```

## Development Workflow

### Making Changes

1. **Language Modules**: Modify files in `src/languages/[language]/`
2. **Core Library**: Update `src/lib/mkBufrnix.nix` or option definitions
3. **Documentation**: Edit files in `doc/src/content/docs/`
4. **Examples**: Add or modify examples in `examples/`

### Testing Changes

1. **Test examples**: Run `./check-examples.sh` to verify all examples work
2. **Test specific language**: Navigate to relevant example and run `nix run`
3. **Test documentation**: Build docs with `cd doc && bun run build`
4. **Lint code**: Run `nix fmt` and `lint` commands

### Adding New Features

1. **Plugin Support**: Add new plugin configurations to language modules
2. **Language Support**: Follow the language addition process above
3. **Configuration Options**: Update `bufrnix-options.nix` with new options
4. **Documentation**: Update relevant docs and add examples

## File Organization

### Important Files

- **`flake.nix`**: Main Nix flake definition with package exports
- **`src/lib/mkBufrnix.nix`**: Core Bufrnix package creation function
- **`src/lib/bufrnix-options.nix`**: Configuration schema and validation
- **`src/languages/*/default.nix`**: Language-specific implementations
- **`check-examples.sh`**: Script to verify all examples work correctly

### Directory Structure Patterns

```
examples/[language]-[type]/
├── flake.nix                 # Bufrnix configuration
├── proto/                    # Protocol buffer definitions
│   └── example/v1/
├── gen/ or src/proto/        # Generated code output
└── README.md                 # Example documentation

src/languages/[language]/
├── default.nix              # Main language module
├── [plugin].nix             # Plugin-specific configurations
└── README.md                # Language documentation
```

## Troubleshooting

### Common Issues

1. **Missing Dependencies**: Ensure Nix flakes are enabled and all inputs are properly defined
2. **Generation Failures**: Check `debug.enable = true` for detailed error output
3. **Plugin Errors**: Verify plugin compatibility with your protobuf schema
4. **Path Issues**: Ensure `sourceDirectories` and `includeDirectories` are correct

### Debug Configuration

```nix
debug = {
  enable = true;
  verbosity = 3;           # Maximum verbosity
  logFile = "debug.log";   # Log to file for analysis
};
```

### Performance Optimization

- Use specific `files` list instead of compiling all `.proto` files
- Enable only required plugins to reduce generation time
- Leverage Nix caching for faster rebuilds

## Contributing Guidelines

### Code Style

- Follow existing Nix formatting conventions (use `nix fmt`)
- Add comprehensive documentation for new features
- Include working examples for new language support
- Test changes with `./check-examples.sh`

### Pull Request Process

1. Fork repository and create feature branch
2. Make changes with appropriate tests
3. Update documentation as needed
4. Ensure all examples pass `check-examples.sh`
5. Submit pull request with clear description

### Example Quality Standards

- Each example should be self-contained and runnable
- Include comprehensive README with setup instructions
- Demonstrate language-specific best practices
- Cover both basic and advanced use cases

## Security Considerations

- All code generation happens locally (no network dependencies)
- Protobuf schemas never leave your environment
- Plugin execution is sandboxed through Nix
- Cryptographic verification of all dependencies

## Performance Notes

- Nix caching significantly improves rebuild times
- Parallel code generation across languages and plugins
- Content-addressed storage prevents redundant work
- Local execution typically 60x faster than remote alternatives

---

## Quick Reference

### Essential Commands
```bash
nix develop      # Enter development environment
nix run          # Generate protobuf code
nix fmt          # Format all files
lint             # Run Nix linting
./check-examples.sh  # Test all examples
```

### Key Configuration Sections
```nix
config = {
  root = ./.;                    # Project root
  protoc = { ... };              # Protoc configuration
  languages = { ... };           # Language-specific settings
  debug = { ... };               # Debug options
};
```

This project emphasizes **reproducibility**, **developer experience**, and **local-first development** while maintaining compatibility with the broader Protocol Buffers ecosystem.