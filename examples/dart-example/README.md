# Dart Example for Bufrnix

This example demonstrates how to use Bufrnix to generate Dart code from Protocol Buffer definitions, including both basic protobuf messages and gRPC service definitions.

## Features Demonstrated

- **Complex Protobuf Messages**: Demonstrates various field types including:
  - Basic types (int32, string)
  - Repeated fields
  - Optional fields
  - Nested messages
  - Timestamps

- **gRPC Service Definition**: Shows a complete CRUD service with:
  - Unary RPCs (Create, Get, Delete)
  - Streaming RPCs (Watch)
  - Request/Response message patterns
  - Pagination support

- **Dart Integration**: Complete Dart application showing:
  - Message creation and manipulation
  - Serialization/deserialization
  - gRPC client implementation
  - Comprehensive testing

## Project Structure

```
dart-example/
├── flake.nix                 # Nix flake configuration
├── pubspec.yaml             # Dart dependencies
├── lib/
│   ├── main.dart           # Main application demonstrating protobuf usage
│   └── grpc_client_example.dart  # gRPC client example
├── proto/
│   └── example/v1/
│       └── example.proto   # Protocol buffer definitions
├── proto/gen/dart/         # Generated Dart code (created by bufrnix)
└── test/
    └── example_test.dart   # Comprehensive tests
```

## Quick Start

### Prerequisites

- Nix with flakes enabled
- Basic familiarity with Dart and Protocol Buffers

### Generate Protobuf Code

1. Build the project to generate Dart protobuf code:
   ```bash
   nix build
   ```

   This will:
   - Set up the development environment
   - Generate Dart protobuf and gRPC code in `proto/gen/dart/`
   - Create all necessary message classes and service stubs

2. Enter the development shell:
   ```bash
   nix develop
   ```

### Run the Example

1. Install Dart dependencies:
   ```bash
   dart pub get
   ```

2. Run the main example:
   ```bash
   dart run lib/main.dart
   ```

3. Run the tests:
   ```bash
   dart test
   ```

### Explore the Generated Code

After running `nix build`, explore the generated files:

```bash
# List generated Dart files
find proto/gen/dart -name "*.dart" | head -10

# View the main protobuf message classes
cat proto/gen/dart/example/v1/example.pb.dart

# View the gRPC service client
cat proto/gen/dart/example/v1/example.pbgrpc.dart
```

## Configuration

The Bufrnix configuration in `flake.nix` shows:

```nix
languages.dart = {
  enable = true;
  outputPath = "proto/gen/dart";
  packageName = "example_proto";
  options = [];
  grpc = {
    enable = true;
    options = [];
  };
};
```

### Configuration Options

- `enable`: Enable Dart code generation
- `outputPath`: Directory for generated Dart files
- `packageName`: Dart package name for generated code
- `options`: Additional options for protoc-gen-dart
- `grpc.enable`: Enable gRPC service generation
- `grpc.options`: Additional options for gRPC generation

## What Gets Generated

### Protobuf Messages

For each message in the `.proto` file, you get:
- Dart class with typed fields
- Constructors and factory methods
- Serialization methods (`writeToBuffer()`, `fromBuffer()`)
- JSON conversion methods
- Field presence checks (`hasField()`, `clearField()`)
- Builder pattern support

### gRPC Services

For each service in the `.proto` file, you get:
- Client stub class for making RPC calls
- Server base class for implementing services
- Properly typed request/response methods
- Support for both unary and streaming RPCs

## Example Usage

### Basic Message Usage

```dart
import 'proto/gen/dart/example/v1/example.pb.dart';

// Create a message
final example = ExampleMessage()
  ..id = 1
  ..name = 'John Doe'
  ..email = 'john@example.com'
  ..tags.addAll(['developer', 'dart']);

// Serialize
final bytes = example.writeToBuffer();

// Deserialize
final restored = ExampleMessage.fromBuffer(bytes);
```

### gRPC Client Usage

```dart
import 'package:grpc/grpc.dart';
import 'proto/gen/dart/example/v1/example.pbgrpc.dart';

// Connect to server
final channel = ClientChannel('localhost', port: 50051);
final client = ExampleServiceClient(channel);

// Make RPC call
final request = GetExampleRequest()..id = 1;
final response = await client.getExample(request);

if (response.found) {
  print('Found: ${response.example.name}');
}
```

## Testing

The example includes comprehensive tests covering:

- Message creation and field access
- Serialization/deserialization roundtrips
- Optional field handling
- Repeated field manipulation
- Nested message support
- Request/response message patterns

Run tests with:
```bash
dart test
```

## Dependencies

The example uses these key Dart packages:

- `protobuf`: Core Protocol Buffers runtime
- `grpc`: gRPC client/server implementation
- `fixnum`: 64-bit integer support
- `test`: Testing framework

## Integration with Existing Projects

To integrate this into your own Dart project:

1. Copy the `languages.dart` configuration from `flake.nix`
2. Add your `.proto` files to the `protoc.files` list
3. Update the output path to fit your project structure
4. Add the protobuf dependencies to your `pubspec.yaml`
5. Run `nix build` to generate the Dart code

## Troubleshooting

### Common Issues

1. **Generated code not found**: Make sure you've run `nix build` first
2. **Import errors**: Check that the generated files are in your Dart path
3. **Missing dependencies**: Run `dart pub get` to install required packages
4. **gRPC connection issues**: Ensure your server is running and accessible

### Development Tips

1. Use `nix develop` to ensure consistent development environment
2. Re-run `nix build` after changing `.proto` files
3. Use `dart analyze` to check for issues in generated code
4. Enable hot reload in your IDE for faster development

## Learn More

- [Protocol Buffers Documentation](https://developers.google.com/protocol-buffers)
- [Dart gRPC Guide](https://grpc.io/docs/languages/dart/)
- [Bufrnix Documentation](../../README.md)