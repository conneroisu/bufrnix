# Bufrnix Language Modules

This directory contains language modules for Bufrnix. Each language module provides the necessary configuration and implementation for generating code for a specific programming language using Protocol Buffers.

## Module Structure

Each language module should be organized in its own directory, following this structure:

```
languages/
  ├── go/
  │   ├── default.nix       # Main entry point for Go code generation
  │   ├── grpc.nix          # gRPC plugin for Go
  │   ├── connect.nix       # Connect plugin for Go
  │   ├── gateway.nix       # gRPC-Gateway plugin for Go
  │   └── validate.nix      # Validate plugin for Go
  ├── dart/
  │   ├── default.nix       # Main entry point for Dart code generation
  │   └── grpc.nix          # gRPC plugin for Dart
  ├── js/
  │   ├── default.nix       # Main entry point for JavaScript code generation
  │   ├── grpc-web.nix      # gRPC-Web plugin for JS
  │   └── twirp.nix         # Twirp plugin for JS
  ├── php/
  │   ├── default.nix       # Main entry point for PHP code generation
  │   └── twirp.nix         # Twirp plugin for PHP
  └── ...
```

## Adding a New Language Module

To add support for a new language:

1. Create a new directory under `src/languages/` with the language name
2. Create a `default.nix` file that exports the required attributes
3. Implement any plugin-specific modules as separate files
4. Update the options in `src/lib/bufrnix-options.nix` to include the new language

## Language Module Interface

Each language module must implement the following interface:

```nix
{
  # Runtime inputs required for code generation
  runtimeInputs = [
    # packages required for this language
  ];

  # Protoc plugin configuration
  protocPlugins = [
    # Parameters to pass to protoc for this language
  ];

  # Command options for protoc
  commandOptions = [
    # CLI options to pass to the protoc command
  ];

  # Initialization hooks for this language
  initHooks = ''
    # Shell script code to run during initialization
  '';

  # Code generation hooks for this language
  generateHooks = ''
    # Shell script code to run during code generation
  '';
}
```

See the Go module implementation for a complete example.

## Module Configuration

Language modules are loaded dynamically based on the user's configuration. The configuration schema for each language is defined in `src/lib/bufrnix-options.nix`.

Example configuration:

```nix
languages = {
  go = {
    enable = true;
    outputPath = "gen/go";
    grpc.enable = true;
  };
  dart = {
    enable = true;
    outputPath = "lib/proto";
    packageName = "my_proto";
    grpc.enable = true;
  };
  js = {
    enable = true;
    outputPath = "src/proto";
    grpcWeb.enable = true;
  };
};
```

## Supported Languages

### Go

- **Base support**: Standard protobuf message generation
- **gRPC**: Full gRPC server and client generation
- **Connect**: Connect-Go plugin support
- **Gateway**: gRPC-Gateway for HTTP/JSON transcoding
- **Validate**: protoc-gen-validate for message validation

### Dart

- **Base support**: Standard protobuf message generation with Dart classes
- **gRPC**: gRPC client and server stub generation
- **Features**: Supports all protobuf field types, nested messages, enums, and services

### JavaScript/TypeScript

- **Base support**: Standard protobuf message generation (CommonJS and ES modules)
- **gRPC-Web**: Browser-compatible gRPC client generation
- **Twirp**: Twirp RPC framework support
- **ECMAScript**: Modern JavaScript with ES modules

### PHP

- **Base support**: Standard protobuf message generation
- **Twirp**: Twirp RPC framework support for PHP
