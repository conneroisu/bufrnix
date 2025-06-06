# Python flake-parts Example

This example demonstrates how to use **Bufrnix** with **flake-parts** for modular Nix flake management in Python projects. It showcases protobuf code generation, gRPC services, and proper Python package integration.

## Features

- **Flake-parts integration**: Modular flake configuration using flake-parts
- **Python protobuf generation**: Automatic generation of Python protobuf and gRPC code
- **Complete user service**: Demonstrates CRUD operations with proper message handling
- **Package management**: Shows how to integrate generated code into Python packages
- **Development environment**: Ready-to-use development shell with all dependencies

## Quick Start

```bash
# Enter the development environment (auto-generates proto files)
nix develop

# Run the example application
nix run

# Or run directly with Python
python src/main.py

# Generate protobuf code manually
nix build .#proto
```

## Project Structure

```
python-flake-parts/
├── flake.nix                    # Flake-parts configuration with Bufrnix
├── proto/
│   └── example/v1/
│       └── user.proto           # User service protobuf definition
├── src/
│   └── main.py                  # Example application demonstrating generated code
├── gen/                         # Generated Python protobuf code (auto-created)
└── README.md                    # This file
```

## Configuration

The `flake.nix` file demonstrates several key flake-parts concepts:

### Package Definitions

```nix
packages = {
  # Generate Python protobuf code using Bufrnix
  proto = inputs.bufrnix.lib.mkBufrnixPackage {
    # ... Bufrnix configuration
  };

  # Default package that uses the generated code
  default = pkgs.python3Packages.buildPythonApplication {
    # ... Python package configuration
  };
};
```

### Development Shell

```nix
devShells.default = pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python3Packages.protobuf
    python3Packages.grpcio
    # ... other dependencies
  ];
  
  shellHook = ''
    # Auto-generate proto files when entering the shell
    # ... shell setup
  '';
};
```

## Protocol Buffers

The example defines a complete user management service with:

- **User message**: Complete user entity with preferences and timestamps
- **UserService**: gRPC service with CRUD operations
- **Request/Response messages**: Proper message design patterns
- **Enums**: User status enumeration
- **Nested messages**: User preferences as a nested message

## Example Application

The Python application (`src/main.py`) demonstrates:

1. **Message Creation**: Creating protobuf messages with proper field assignment
2. **Service Simulation**: Mock implementation of the UserService
3. **Enum Handling**: Working with protobuf enumerations
4. **Serialization**: Binary serialization and deserialization
5. **Pagination**: Implementing pagination patterns with protobuf
6. **Timestamp Handling**: Working with Google's timestamp types

## Generated Code

Bufrnix generates the following Python files:

```
gen/
└── example/
    └── v1/
        ├── __init__.py
        ├── user_pb2.py          # Message classes
        └── user_pb2_grpc.py     # gRPC service stubs
```

## Development Workflow

### 1. Modify Protocol Buffers

Edit files in `proto/example/v1/` to modify your service definitions.

### 2. Regenerate Code

```bash
# Regenerate protobuf code
nix build .#proto --rebuild

# Or restart the development shell
exit
nix develop
```

### 3. Update Application

Modify `src/main.py` to use your new protobuf definitions.

### 4. Test Changes

```bash
# Run the example
nix run

# Or test directly
python src/main.py
```

## Flake-parts Benefits

This example showcases several flake-parts advantages:

1. **Modular Configuration**: Clean separation between proto generation and application packages
2. **Per-system Outputs**: Automatic handling of multiple system architectures
3. **Composable Packages**: Easy composition of generated code with application packages
4. **Development Environment**: Integrated development shell with automatic setup

## Integration with Existing Projects

To integrate this pattern into your own project:

1. **Add flake-parts**: Include flake-parts in your flake inputs
2. **Configure Bufrnix**: Set up Bufrnix package generation for your protos
3. **Create Application Package**: Build your application using the generated code
4. **Development Shell**: Set up a development environment with auto-generation

## Common Patterns

### Multiple Languages

```nix
packages = {
  proto-python = inputs.bufrnix.lib.mkBufrnixPackage {
    # Python configuration
  };
  
  proto-go = inputs.bufrnix.lib.mkBufrnixPackage {
    # Go configuration
  };
};
```

### Multiple Services

```nix
packages = {
  user-service = inputs.bufrnix.lib.mkBufrnixPackage {
    config.protoc.files = [ "./proto/user/v1/user.proto" ];
  };
  
  order-service = inputs.bufrnix.lib.mkBufrnixPackage {
    config.protoc.files = [ "./proto/order/v1/order.proto" ];
  };
};
```

## Example Output

When you run the example, you'll see:

```
🔧 Bufrnix Python flake-parts Example
==================================================

📝 Creating sample users...
  ✓ Created user: User 1 (user1@example.com)
  ✓ Created user: User 2 (user2@example.com)
  ✓ Created user: User 3 (user3@example.com)

🆕 Creating user via CreateUserRequest...
  ✓ Created: John Doe (ID: 4)

🔍 Getting user by ID...
  ✓ Found user: User 1
    Email: user1@example.com
    Age: 25
    Status: USER_STATUS_ACTIVE
    Notifications: Email=True, SMS=False

📋 Listing all users...
  ✓ Found 4 active users (total: 4)
    - User 1 (user1@example.com) - USER_STATUS_ACTIVE
    - User 2 (user2@example.com) - USER_STATUS_ACTIVE
    - User 3 (user3@example.com) - USER_STATUS_ACTIVE
    - John Doe (john.doe@example.com) - USER_STATUS_ACTIVE

🏷️  Demonstrating enum usage...
  Status 1: USER_STATUS_ACTIVE
  Status 2: USER_STATUS_INACTIVE
  Status 3: USER_STATUS_SUSPENDED

💾 Demonstrating serialization...
  ✓ Serialized user to 150 bytes
  ✓ Deserialized user: User 1
  ✓ Serialization roundtrip successful

🎉 Example completed successfully!
```

## Next Steps

- Explore the [multilang-multi-project](../multilang-multi-project/) example for complex multi-language setups
- Check out [python-grpc](../python-grpc/) for gRPC server implementation
- See [go-flake-parts](../go-flake-parts/) for Go-specific flake-parts usage

## Troubleshooting

### Import Errors

If you get import errors for generated modules:

```bash
# Make sure you're in the development environment
nix develop

# Check if proto files were generated
ls gen/example/v1/
```

### Missing Dependencies

If protobuf imports fail:

```bash
# Verify Python packages are available
python -c "import google.protobuf; print('✓ protobuf available')"
python -c "import grpc; print('✓ grpc available')"
```

### Generation Issues

If proto generation fails:

```bash
# Enable debug mode and check logs
nix build .#proto --show-trace
```