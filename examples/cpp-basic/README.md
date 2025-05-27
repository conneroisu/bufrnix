# Basic C++ Protobuf Example

This example demonstrates basic C++ protobuf code generation using Bufrnix.

## Features

- **Protocol Buffer messages** with various field types
- **Nested messages** and enums
- **JSON serialization** support
- **Timestamp handling** with protobuf utilities
- **File I/O** for binary protobuf data
- **CMake integration** for building

## Generated Files

Bufrnix generates the following C++ files from `proto/example/v1/person.proto`:

- `proto/gen/cpp/example/v1/person.pb.h` - Header file with message declarations
- `proto/gen/cpp/example/v1/person.pb.cc` - Implementation file with message definitions

## Usage

### Development Shell

```bash
nix develop
```

This provides all necessary tools:

- CMake
- Ninja (fast build system)
- GCC compiler
- Protocol Buffers
- Development tools (gdb, valgrind)

### Building

```bash
# Configure with Ninja generator for faster builds
cmake -B build -G Ninja

# Build the project
cmake --build build

# Run the example
./build/cpp-basic-example

# Save data to file
./build/cpp-basic-example addressbook.dat
```

### Configuration

The protobuf generation is configured in `flake.nix`:

```nix
languages.cpp = {
  enable = true;
  protobufVersion = "latest";
  standard = "c++20";
  optimizeFor = "SPEED";
  cmakeIntegration = true;
  outputPath = "proto/gen/cpp";
  options = [
    "paths=source_relative"
  ];
};
```

## Code Structure

- `src/main.cpp` - Example application demonstrating:

  - Creating protobuf messages
  - Setting various field types
  - JSON serialization
  - Binary file I/O
  - Multiple messages in collections

- `proto/example/v1/person.proto` - Protocol definition with:
  - Basic message types
  - Nested messages
  - Enums
  - Timestamps
  - Repeated fields

## Dependencies

All dependencies are managed through Nix:

- **Protocol Buffers** - Core protobuf library
- **CMake** - Build system
- **GCC/Clang** - C++ compiler
- **pkg-config** - Package configuration

## Performance

This example uses:

- **C++20** for modern language features
- **SPEED optimization** for generated code
- **Efficient binary serialization**
- **Optional JSON output** for debugging

## Next Steps

Try the more advanced examples:

- `cpp-grpc` - gRPC services with client/server
- `cpp-cmake-integration` - Advanced CMake usage
- `cpp-embedded` - Embedded C++ with nanopb

