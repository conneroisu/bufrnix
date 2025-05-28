# SVG Diagram Generation Example

This example demonstrates how to use bufrnix to generate SVG diagrams from Protocol Buffer files using the `protoc-gen-d2` plugin.

## What This Example Shows

- SVG diagram generation from `.proto` files
- Visual representation of:
  - Message structures and relationships
  - Service definitions and RPC methods
  - Enum types and their values
  - Field types and connections between messages

## Structure

```
svg-example/
├── flake.nix                    # Nix flake configuration
├── proto/
│   └── example/
│       └── v1/
│           └── example.proto    # Example proto file with complex relationships
└── proto/gen/                   # Generated output (after building)
    ├── svg/                     # SVG diagrams
    ├── go/                      # Go code (for comparison)
    └── doc/                     # HTML documentation
```

## Building

```bash
# Generate SVG diagrams, Go code, and documentation
nix build

# The generated files will be in:
# - result/proto/gen/svg/    - SVG diagrams
# - result/proto/gen/go/     - Go code
# - result/proto/gen/doc/    - HTML documentation
```

## Proto File Features

The example proto file demonstrates:

- Complex message relationships (User -> Phone, User -> Address)
- Enum types (UserStatus, PhoneType)
- Service with multiple RPC methods
- Google protobuf imports (Timestamp, FieldMask)
- Repeated fields and nested messages

## Generated SVG Output

The generated SVG diagrams will show:

- All messages as nodes with their fields
- Relationships between messages as edges
- Enum values within enum nodes
- Service methods with request/response types
- Clear visual hierarchy of the protocol buffer schema

## Viewing the Diagrams

After building, open the generated SVG files in your browser or any SVG viewer:

```bash
# Build and view
nix build
open result/proto/gen/svg/*.svg
```

## Notes

- The `protoc-gen-d2` plugin generates D2 diagram language files
- These are then rendered to SVG using the D2 runtime
- The SVG generation happens automatically as part of the bufrnix build process
- Multiple proto files will generate multiple SVG diagrams

## Customization

You can customize the SVG generation by passing options to the plugin:

```nix
languages.svg = {
  enable = true;
  outputPath = "proto/gen/svg";
  options = [
    # Add any protoc-gen-d2 specific options here
  ];
};
```
