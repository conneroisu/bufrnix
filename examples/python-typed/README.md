# Python Type Stubs Example

This example demonstrates generating Python code with type stubs for better IDE support and static type checking with mypy.

## Features

- Python protobuf message generation
- gRPC service generation
- Type stub (.pyi) files for static type checking
- mypy integration for type validation
- Full IDE autocomplete support

## Usage

```bash
# Enter development shell
nix develop

# Generate protobuf code with type stubs
bufrnix

# Run the example
python test_types.py

# Type check with mypy
mypy test_types.py
```

## Configuration

The example uses mypy to generate type stubs, providing:
- Full type hints for all generated classes
- IDE autocomplete support
- Static type checking with mypy

The `mypy.ini` file configures mypy to find the generated modules and ignore missing imports for third-party libraries.