# Basic Python Protobuf Example

This example demonstrates basic Python protobuf generation without any additional features.

## What's Generated

- `*_pb2.py` - Python protobuf message classes
- `__init__.py` - Python package files

## Usage

```bash
# Enter development shell
nix develop

# Initialize and generate code
bufrnix_init
bufrnix

# Run the test
python test.py
```

## Configuration

```nix
languages.python = {
  enable = true;
  outputPath = "proto/gen/python";
};
```

This is the minimal configuration for Python protobuf generation.
