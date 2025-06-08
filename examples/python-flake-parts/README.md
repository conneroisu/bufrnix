# Python Flake-Parts Example

This example demonstrates how to use [Bufrnix](https://github.com/conneroisu/bufrnix) with [flake-parts](https://flake.parts) to generate Python protobuf code with gRPC support.

## Quick Start

```bash
# Navigate to the example
cd examples/python-flake-parts

# Generate the protobuf code
nix build

# Enter the development shell
nix develop
```

The generated Python files will be placed in `proto/gen/python`.
