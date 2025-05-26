# Python Bufrnix Example

This example demonstrates how to use Bufrnix to generate Python protobuf code with various options including gRPC support, type stubs, and mypy integration.

## Features Demonstrated

- **Basic Protobuf Generation**: Standard Python protobuf classes
- **gRPC Support**: Generate gRPC service stubs and clients
- **Type Stubs (.pyi)**: Better IDE support with type hints
- **Mypy Integration**: Static type checking for generated code
- **Betterproto (Optional)**: Modern Python dataclasses approach

## Project Structure

```
python-example/
├── flake.nix              # Nix flake configuration
├── proto/
│   └── example/
│       └── v1/
│           └── example.proto    # Protocol buffer definitions
├── main.py                # Example Python client code
├── test_example.py        # Unit tests
└── README.md             # This file
```

## Usage

### 1. Enter the development shell

```bash
nix develop
```

This provides a Python environment with all necessary dependencies.

### 2. Initialize the project

```bash
bufrnix_init
```

This creates the necessary directory structure for code generation.

### 3. Generate Python code

```bash
bufrnix
```

This generates Python code in `proto/gen/python/` with:

- Protocol buffer message classes (`*_pb2.py`)
- gRPC service stubs (`*_pb2_grpc.py`)
- Type stubs for IDE support (`*.pyi`)
- Mypy stubs for static type checking

### 4. Run the example

```bash
python main.py
```

This demonstrates:

- Creating and manipulating protobuf messages
- Serialization/deserialization (binary and JSON)
- Type-safe field access
- Async patterns

### 5. Run tests

```bash
pytest -v
```

## Configuration Options

The `flake.nix` file shows various configuration options:

```nix
languages.python = {
  enable = true;
  outputPath = "proto/gen/python";

  # Enable gRPC service generation
  grpc = {
    enable = true;
    options = [];
  };

  # Enable type stub generation for IDEs
  pyi = {
    enable = true;
    options = [];
  };

  # Enable mypy stubs for type checking
  mypy = {
    enable = true;
    options = [];
  };

  # Optional: Use betterproto for modern dataclasses
  betterproto = {
    enable = false;  # Set to true to use betterproto
    options = [];
  };
};
```

## Generated Code Structure

After running `bufrnix`, you'll find:

```
proto/gen/python/
├── __init__.py
└── example/
    ├── __init__.py
    └── v1/
        ├── __init__.py
        ├── example_pb2.py       # Protobuf messages
        ├── example_pb2.pyi      # Type stubs
        ├── example_pb2_grpc.py  # gRPC service stubs
        └── example_pb2_grpc.pyi # gRPC type stubs
```

## Working with Generated Code

### Basic Message Usage

```python
from proto.gen.python.example.v1 import example_pb2

# Create a message
greeting = example_pb2.Greeting(
    id="123",
    content="Hello, World!",
    tags=["example", "python"]
)

# Serialize to bytes
data = greeting.SerializeToString()

# Deserialize from bytes
restored = example_pb2.Greeting()
restored.ParseFromString(data)
```

### gRPC Client Usage

```python
import grpc
from proto.gen.python.example.v1 import example_pb2_grpc

# Create a channel and stub
channel = grpc.insecure_channel('localhost:50051')
stub = example_pb2_grpc.GreetingServiceStub(channel)

# Make RPC calls
response = stub.CreateGreeting(request)
```

### Type Checking with Mypy

The generated type stubs enable static type checking:

```bash
mypy main.py
```

## Troubleshooting

1. **Import Errors**: Make sure to run `bufrnix` first to generate the code
2. **gRPC Connection Failed**: The gRPC client example requires a server running on `localhost:50051`
3. **Type Checking Issues**: Ensure mypy is installed and type stubs are generated

## Next Steps

- Explore different protobuf options in the configuration
- Try enabling betterproto for a more Pythonic API
- Implement a gRPC server using the generated service stubs
- Add custom protoc plugins for specialized code generation
