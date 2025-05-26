# Python Examples Overview

This directory contains examples demonstrating all Python code generation configurations supported by Bufrnix.

## Examples

### 1. python-basic

Basic Python protobuf generation without additional features.

- Generates: `*_pb2.py` files
- Use case: Simple message serialization/deserialization

### 2. python-grpc

Python with gRPC service support.

- Generates: `*_pb2.py` and `*_pb2_grpc.py` files
- Use case: Building gRPC servers and clients

### 3. python-typed

Python with type stubs for IDE support and static type checking.

- Generates: `*_pb2.py`, `*.pyi`, and `py.typed` marker
- Use case: Projects using mypy or requiring strong IDE support

### 4. python-betterproto

Modern Python approach using dataclasses.

- Generates: Python files with `@dataclass` decorators
- Use case: Projects wanting more Pythonic API

### 5. python-example (Full Featured)

Comprehensive example with all features enabled.

- Generates: All of the above
- Use case: Exploring all capabilities

## Running the Examples

Each example has a `test.sh` script:

```bash
cd examples/python-basic
nix develop
./test.sh
```

## Configuration Comparison

| Feature       | basic | grpc | typed | betterproto | full |
| ------------- | ----- | ---- | ----- | ----------- | ---- |
| Base protobuf | ✓     | ✓    | ✓     | ✗           | ✓    |
| gRPC services | ✗     | ✓    | ✓     | ✓\*         | ✓    |
| Type stubs    | ✗     | ✗    | ✓     | ✗           | ✓    |
| Mypy support  | ✗     | ✗    | ✓     | ✗           | ✓    |
| Dataclasses   | ✗     | ✗    | ✗     | ✓           | ✓    |

\*Betterproto uses grpclib instead of grpcio

## Choosing a Configuration

- **Basic**: When you only need message serialization
- **gRPC**: When building gRPC services with standard tooling
- **Typed**: When using type checkers or wanting better IDE support
- **Betterproto**: When you prefer modern Python patterns (async, dataclasses)
- **Full**: When experimenting or needing maximum flexibility
