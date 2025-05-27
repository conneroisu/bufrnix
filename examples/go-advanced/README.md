# Advanced Go Protobuf Example

This example demonstrates the comprehensive Go plugin support in Bufrnix, including:

- **High-performance serialization** with vtprotobuf (3.8x faster)
- **JSON integration** for encoding/json compatibility
- **OpenAPI v2 documentation** generation
- **gRPC service** generation

## Features Demonstrated

### 1. VTProtobuf Performance Enhancement

VTProtobuf provides optimized marshal/unmarshal operations with:

- 3.8x faster serialization
- Memory pooling support
- Compatible with standard protobuf code

### 2. JSON Integration

The go-json plugin enables seamless integration with Go's `encoding/json`:

```go
// Standard JSON marshaling works with generated types
data, err := json.Marshal(myProtoMessage)
```

### 3. OpenAPI Documentation

Automatically generates OpenAPI v2 specifications from your proto files,
perfect for REST API documentation.

## Usage

```bash
# Enter development shell
nix develop

# Generate code
nix build

# View generated files
ls proto/gen/go/
ls proto/gen/openapi/
```

## Configuration Options

### Method 1: Individual Plugin Configuration

```nix
go = {
  enable = true;
  grpc.enable = true;
  openapiv2.enable = true;
  vtprotobuf = {
    enable = true;
    options = ["features=marshal+unmarshal+size+pool"];
  };
  json.enable = true;
};
```

### Method 2: Buf Registry Plugin Names

```nix
go = {
  enable = true;
  plugins = [
    "buf.build/protocolbuffers/go"
    "buf.build/grpc/go"
    {
      plugin = "buf.build/community/planetscale-vtprotobuf";
      opt = ["features=marshal+unmarshal+size+pool"];
    }
    "buf.build/community/mfridman-go-json"
  ];
};
```

## Performance Benchmarks

When using vtprotobuf with all features enabled:

- Marshal: ~3.8x faster
- Unmarshal: ~3.5x faster
- Size calculation: ~5x faster
- Memory usage: Significantly reduced with pooling

## Custom Package Definitions

Since some plugins aren't yet in nixpkgs, this example shows how to define them:

```nix
protoc-gen-go-vtproto = pkgs.buildGoModule rec {
  pname = "protoc-gen-go-vtproto";
  version = "0.6.0";
  # ... full definition in flake.nix
};
```

## Migration from Legacy Validate

To migrate from `protoc-gen-validate` to `protovalidate`:

1. Replace validation rules in proto files with CEL expressions
2. Enable `protovalidate` instead of `validate`
3. Update validation code to use runtime validation

Example:

```proto
// Old (protoc-gen-validate)
string email = 1 [(validate.rules).string.email = true];

// New (protovalidate)
string email = 1 [(buf.validate.field).string.email = true];
```
