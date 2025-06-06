# Multiple Output Paths Example

This example demonstrates Bufrnix's **multiple output paths** feature, which allows you to generate the same protobuf code to multiple directories simultaneously. This is useful for:

- **Multi-module projects** where the same protobuf definitions need to be available in different modules
- **Shared libraries** that need to be distributed to multiple locations
- **Development vs. distribution** scenarios where you need code in both source and package directories
- **Microservices architectures** where common protobuf definitions are shared across services

## Features Demonstrated

### 🚀 Multiple Output Paths per Language

This example shows how to configure multiple output paths for different languages:

**Go Language** - Four different output locations:

- `gen/go` - Main generated code location
- `pkg/shared/proto` - Shared package for internal use
- `vendor/proto` - Vendor directory for dependencies
- `services/common/proto` - Common location for microservices

**JavaScript/TypeScript** - Four different output locations:

- `packages/frontend/src/proto` - Frontend package
- `packages/backend/src/proto` - Backend package
- `packages/shared/proto` - Shared utilities
- `dist/npm-package/proto` - Distribution package for npm

**Python** - Four different output locations:

- `gen/python` - Main development location
- `src/mypackage/proto` - Package source location
- `dist/mypackage/proto` - Distribution package
- `tests/fixtures/proto` - Test fixtures

### 🔧 Plugin Support

Each language demonstrates multiple output paths working with various plugins:

- **Go**: Basic protobuf + gRPC + validation
- **JavaScript**: ES modules + Connect-ES for modern RPC
- **Python**: Basic protobuf + gRPC + type stubs (.pyi files)

## Project Structure

```
multi-output-example/
├── flake.nix                           # Bufrnix configuration
├── README.md                           # This file
├── proto/
│   └── example/v1/
│       ├── user.proto                  # User service definitions
│       └── product.proto               # Product service definitions
└── [Generated directories]
    ├── gen/
    │   ├── go/                         # Main Go output
    │   ├── python/                     # Main Python output
    ├── pkg/shared/proto/               # Go shared package
    ├── vendor/proto/                   # Go vendor directory
    ├── services/common/proto/          # Go microservices common
    ├── packages/
    │   ├── frontend/src/proto/         # JS frontend package
    │   ├── backend/src/proto/          # JS backend package
    │   └── shared/proto/               # JS shared utilities
    ├── dist/
    │   ├── npm-package/proto/          # JS distribution
    │   └── mypackage/proto/            # Python distribution
    ├── src/mypackage/proto/            # Python package source
    └── tests/fixtures/proto/           # Python test fixtures
```

## Usage

### Generate Code

```bash
# Generate protobuf code to all configured output paths
nix run

# Enter development environment
nix develop
```

### Verify Multiple Outputs

After running `nix run`, you can verify that the same code was generated to multiple locations:

```bash
# Check Go outputs
ls gen/go/example/v1/                   # Main output
ls pkg/shared/proto/example/v1/         # Shared package
ls vendor/proto/example/v1/             # Vendor directory
ls services/common/proto/example/v1/    # Microservices common

# Check JavaScript outputs
ls packages/frontend/src/proto/example/v1/
ls packages/backend/src/proto/example/v1/
ls packages/shared/proto/example/v1/
ls dist/npm-package/proto/example/v1/

# Check Python outputs
ls gen/python/example/v1/
ls src/mypackage/proto/example/v1/
ls dist/mypackage/proto/example/v1/
ls tests/fixtures/proto/example/v1/
```

## Configuration Breakdown

### Array-Based Output Paths

The key feature is using arrays instead of strings for `outputPath`:

```nix
# Before (single path)
outputPath = "gen/go";

# After (multiple paths)
outputPath = [
  "gen/go"
  "pkg/shared/proto"
  "vendor/proto"
  "services/common/proto"
];
```

### Language-Specific Examples

**Go with Multiple gRPC Outputs:**

```nix
go = {
  enable = true;
  outputPath = ["gen/go" "pkg/shared/proto" "vendor/proto"];
  grpc = {
    enable = true;
    outputPath = ["gen/go/grpc" "pkg/shared/proto/grpc"];
  };
};
```

**JavaScript with Module Distribution:**

```nix
js = {
  enable = true;
  outputPath = [
    "packages/frontend/src/proto"
    "packages/backend/src/proto"
    "packages/shared/proto"
    "dist/npm-package/proto"
  ];
  es = {
    enable = true;
    target = "ts";
  };
};
```

## Real-World Use Cases

### 1. **Microservices Architecture**

```nix
outputPath = [
  "services/user/proto"     # User service
  "services/order/proto"    # Order service
  "services/inventory/proto" # Inventory service
  "pkg/common/proto"        # Shared definitions
];
```

### 2. **Multi-Package Monorepo**

```nix
outputPath = [
  "packages/core/src/proto"     # Core package
  "packages/client/src/proto"   # Client package
  "packages/server/src/proto"   # Server package
  "tools/testing/proto"         # Testing utilities
];
```

### 3. **Development + Distribution**

```nix
outputPath = [
  "src/proto"                   # Development location
  "dist/lib/proto"              # Library distribution
  "examples/generated/proto"    # Example code
  "docs/api/proto"              # Documentation
];
```

## Advanced Features

### Debug Mode

The example enables debug mode to show detailed generation information:

```nix
debug = {
  enable = true;
  verbosity = 2;  # Show detailed output for each path
};
```

### Backward Compatibility

The multiple output paths feature is fully backward compatible. Existing single-path configurations continue to work:

```nix
# This still works exactly as before
outputPath = "gen/go";
```

## Benefits

1. **🔄 Code Reuse**: Generate the same protobuf code to multiple locations without duplication
2. **📦 Multi-Module Support**: Support complex project structures with multiple modules
3. **🚀 Distribution Flexibility**: Generate code for both development and distribution simultaneously
4. **🏗️ Microservices Architecture**: Easily share proto definitions across multiple services
5. **📚 Vendor Management**: Generate to both local and vendor directories
6. **🧪 Testing Support**: Generate test fixtures alongside production code

## Next Steps

- Modify the `outputPath` arrays in `flake.nix` to match your project structure
- Add or remove languages based on your needs
- Customize the proto files for your specific use case
- Explore advanced plugin configurations for each output location

This example provides a solid foundation for understanding and implementing multiple output paths in your own Bufrnix projects!
