# Swift Example

This example demonstrates how to use bufrnix to generate Swift code from Protocol Buffer definitions.

## Prerequisites

- Nix with flakes enabled
- Swift compiler (provided by the dev shell)

## Usage

1. Enter the development shell:

   ```bash
   nix develop
   ```

2. Initialize the proto structure:

   ```bash
   bufrnix_init
   ```

3. Generate Swift code from proto files:

   ```bash
   bufrnix
   ```

4. Build and run the Swift example:
   ```bash
   swift build
   swift run
   ```

## Project Structure

```
.
├── flake.nix          # Nix flake configuration
├── Package.swift      # Swift Package Manager configuration
├── proto/             # Protocol Buffer definitions
│   └── example/
│       └── v1/
│           └── example.proto
├── proto/gen/swift/   # Generated Swift code
└── Sources/           # Swift source code
    └── SwiftExample/
        └── main.swift
```

## Customization

You can customize the Swift code generation by modifying the `flake.nix` file:

```nix
config = {
  languages = {
    swift = {
      enable = true;
      outputPath = "proto/gen/swift";
      options = [
        # Add protoc-gen-swift options here
      ];
    };
  };
};
```

## Available Options

- `enable`: Enable/disable Swift code generation
- `outputPath`: Directory where generated Swift files will be placed
- `options`: Additional options to pass to `protoc-gen-swift`
- `packageName`: Swift package name for generated code
