# Packages

This directory contains per-package subdirectories for Bufrnix package definitions.

## Structure

Each package should have its own subdirectory containing:

- `default.nix` - The Nix package definition for building the package
- `update-hash.py` - A Python script to update the package to the latest version and regenerate hashes

## Usage

### Building a Package

```bash
# Build a specific package
nix-build -E '(import <nixpkgs> {}).callPackage ./src/packages/protoc-gen-go-json {}'
```

### Updating a Package

```bash
# Update to latest version
cd src/packages/protoc-gen-go-json
python3 update-hash.py
```

## Packages

- **protoc-gen-go-json**: Protocol buffer compiler plugin for Go JSON marshaling
- **protoc-gen-go-vtproto**: Protocol buffer compiler plugin for Go with vtprotobuf optimizations  
- **protoc-gen-openapiv2**: Protocol buffer compiler plugin for OpenAPI v2 (Swagger) generation

## Adding New Packages

1. Create a new subdirectory under `src/packages/`
2. Add a `default.nix` file with the package definition
3. Create an `update-hash.py` script based on the existing examples
4. Update language modules in `src/languages/` to reference the new package
5. Test that the package builds and update script work correctly
