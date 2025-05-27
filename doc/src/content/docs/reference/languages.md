---
title: Language Support
description: Complete guide to all languages supported by Bufrnix with examples and configuration options.
---

# Introduction

Bufrnix supports code generation for multiple programming languages through a modular plugin system. Each language implementation provides comprehensive Protocol Buffer support with language-specific optimizations and ecosystem integrations.

## Overview

All examples shown below are fully functional and can be found in the [`examples/`](https://github.com/conneroisu/bufr.nix/tree/main/examples) directory. Each example includes:

- Complete `flake.nix` configuration
- Sample `.proto` files demonstrating various features
- Generated code examples
- Integration patterns and best practices
- Working applications you can run immediately

## Go

**Status**: ✅ Full Support  
**Example**: [`examples/simple-flake/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/simple-flake)

Go support includes the complete Protocol Buffer ecosystem with all major plugins.

### Available Plugins

| Plugin                        | Description             | Generated Files    |
| ----------------------------- | ----------------------- | ------------------ |
| **`protoc-gen-go`**           | Base message generation | `*.pb.go`          |
| **`protoc-gen-go-grpc`**      | gRPC services           | `*_grpc.pb.go`     |
| **`protoc-gen-connect-go`**   | Connect protocol        | `*_connect.go`     |
| **`protoc-gen-grpc-gateway`** | HTTP/JSON gateway       | `*.pb.gw.go`       |
| **`protoc-gen-validate`**     | Message validation      | `*.pb.validate.go` |

### Configuration

```nix
languages.go = {
  enable = true;
  outputPath = "gen/go";
  packagePrefix = "github.com/myorg/myproject";
  options = [
    "paths=source_relative"
    "require_unimplemented_servers=false"
  ];

  # gRPC service generation
  grpc = {
    enable = true;
    options = [
      "paths=source_relative"
      "require_unimplemented_servers=false"
    ];
  };

  # HTTP/JSON gateway for REST APIs
  gateway = {
    enable = true;
    options = [
      "paths=source_relative"
      "generate_unbound_methods=true"
    ];
  };

  # Message validation
  validate = {
    enable = true;
    options = ["lang=go"];
  };

  # Modern Connect protocol
  connect = {
    enable = true;
    options = ["paths=source_relative"];
  };
};
```

### Proto Example

```protobuf
// proto/user/v1/user.proto
syntax = "proto3";

package userservice;

option go_package = "github.com/myorg/myproject/gen/go/user/v1;userservice";

message User {
  string id = 1;
  string name = 2;
  string email = 3;
  int32 age = 4;
  repeated string roles = 5;
  UserStatus status = 6;
  repeated Address addresses = 7;

  message Address {
    string street = 1;
    string city = 2;
    string state = 3;
    string zip = 4;
    string country = 5;
  }
}

enum UserStatus {
  UNKNOWN = 0;
  ACTIVE = 1;
  INACTIVE = 2;
  SUSPENDED = 3;
}

service UserService {
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
  rpc GetUser(GetUserRequest) returns (GetUserResponse);
}

message CreateUserRequest {
  User user = 1;
}

message CreateUserResponse {
  User user = 1;
  bool success = 2;
  string error = 3;
}

message GetUserRequest {
  string user_id = 1;
}

message GetUserResponse {
  User user = 1;
  bool success = 2;
  string error = 3;
}
```

### Generated Code Usage

```go
package main

import (
    "context"
    "log"
    "net"

    "google.golang.org/grpc"
    pb "github.com/myorg/myproject/gen/go/user/v1"
)

// Server implementation
type server struct {
    pb.UnimplementedUserServiceServer
    users map[string]*pb.User
}

func (s *server) CreateUser(ctx context.Context, req *pb.CreateUserRequest) (*pb.CreateUserResponse, error) {
    user := req.GetUser()
    s.users[user.GetId()] = user

    return &pb.CreateUserResponse{
        User:    user,
        Success: true,
    }, nil
}

func (s *server) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.GetUserResponse, error) {
    user, exists := s.users[req.GetUserId()]
    return &pb.GetUserResponse{
        User:    user,
        Success: exists,
    }, nil
}

func main() {
    lis, err := net.Listen("tcp", ":50051")
    if err != nil {
        log.Fatalf("failed to listen: %v", err)
    }

    s := grpc.NewServer()
    pb.RegisterUserServiceServer(s, &server{
        users: make(map[string]*pb.User),
    })

    log.Println("Server listening on :50051")
    if err := s.Serve(lis); err != nil {
        log.Fatalf("failed to serve: %v", err)
    }
}
```

### Try the Example

```bash
cd examples/simple-flake
nix develop
go run main.go
```

## Dart

**Status**: ✅ Full Support  
**Example**: [`examples/dart-example/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/dart-example)

Dart support provides complete Protocol Buffer and gRPC integration for Flutter and server applications.

### Available Plugins

| Plugin                | Description          | Generated Files                                                |
| --------------------- | -------------------- | -------------------------------------------------------------- |
| **`protoc-gen-dart`** | Base messages & gRPC | `*.pb.dart`, `*.pbgrpc.dart`, `*.pbenum.dart`, `*.pbjson.dart` |

### Configuration

```nix
languages.dart = {
  enable = true;
  outputPath = "lib/proto";
  packageName = "my_app_proto";
  options = [
    "generate_kythe_info"  # IDE support metadata
  ];

  grpc = {
    enable = true;
    options = [
      "generate_metadata"
    ];
  };
};
```

### Proto Example

```protobuf
// proto/example/v1/example.proto
syntax = "proto3";

package example.v1;

message ExampleMessage {
  int32 id = 1;
  string name = 2;
  string email = 3;
  repeated string tags = 4;
  optional string description = 5;
  TimestampMessage created_at = 6;
}

message TimestampMessage {
  int64 seconds = 1;
  int32 nanos = 2;
}

service ExampleService {
  rpc CreateExample(CreateExampleRequest) returns (CreateExampleResponse);
  rpc GetExample(GetExampleRequest) returns (GetExampleResponse);
  rpc ListExamples(ListExamplesRequest) returns (ListExamplesResponse);
  rpc WatchExamples(ListExamplesRequest) returns (stream ExampleMessage);
}

message CreateExampleRequest {
  ExampleMessage example = 1;
}

message CreateExampleResponse {
  ExampleMessage example = 1;
  bool success = 2;
  string message = 3;
}

message GetExampleRequest {
  int32 id = 1;
}

message GetExampleResponse {
  ExampleMessage example = 1;
  bool found = 2;
}

message ListExamplesRequest {
  int32 page_size = 1;
  string page_token = 2;
  string filter = 3;
}

message ListExamplesResponse {
  repeated ExampleMessage examples = 1;
  string next_page_token = 2;
  int32 total_count = 3;
}
```

### Generated Code Usage

```dart
import 'package:grpc/grpc.dart';
import 'lib/proto/example/v1/example.pbgrpc.dart';

Future<void> main() async {
  // Create a gRPC client
  final channel = ClientChannel('localhost', port: 50051);
  final client = ExampleServiceClient(channel);

  try {
    // Create a new example message
    final example = ExampleMessage()
      ..id = 1
      ..name = 'John Doe'
      ..email = 'john@example.com'
      ..tags.addAll(['developer', 'dart'])
      ..description = 'Example user for testing';

    // Make RPC call
    final request = CreateExampleRequest()..example = example;
    final response = await client.createExample(request);

    if (response.success) {
      print('Created example: ${response.example.name}');
    }

    // List examples with pagination
    final listRequest = ListExamplesRequest()
      ..pageSize = 10
      ..filter = 'developer';

    final listResponse = await client.listExamples(listRequest);
    print('Found ${listResponse.examples.length} examples');

    // Watch for streaming updates
    final watchRequest = ListExamplesRequest()..filter = 'live';

    await for (final update in client.watchExamples(watchRequest)) {
      print('Received update: ${update.name}');
    }

  } finally {
    await channel.shutdown();
  }
}
```

### Try the Example

```bash
cd examples/dart-example
nix develop
dart pub get
dart run lib/main.dart
dart test
```

## Python

**Status**: ✅ Full Support  
**Example**: [`examples/python-example/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/python-example)

Python support provides comprehensive Protocol Buffer integration with multiple output options including gRPC, type stubs, and modern dataclass alternatives.

### Available Plugins

| Plugin                              | Description                | Generated Files               |
| ----------------------------------- | -------------------------- | ----------------------------- |
| **`protoc-gen-python`**             | Base message generation    | `*_pb2.py`                    |
| **`protoc-gen-grpc_python`**        | gRPC services              | `*_pb2_grpc.py`               |
| **`protoc-gen-pyi`**                | Type stubs for IDE support | `*_pb2.pyi`                   |
| **`protoc-gen-mypy`**               | Mypy type checking stubs   | `*_pb2.pyi`, `*_pb2_grpc.pyi` |
| **`protoc-gen-python_betterproto`** | Modern dataclass approach  | `*.py` (with @dataclass)      |

### Configuration

```nix
languages.python = {
  enable = true;
  outputPath = "proto/gen/python";
  options = [];

  # gRPC service generation
  grpc = {
    enable = true;
    options = [];
  };

  # Type stubs for better IDE support
  pyi = {
    enable = true;
    options = [];
  };

  # Mypy type checking support
  mypy = {
    enable = true;
    options = [];
  };

  # Modern Python dataclasses (alternative to standard protobuf)
  betterproto = {
    enable = false;  # Opt-in due to performance considerations
    options = [];
  };
};
```

### Proto Example

```protobuf
// proto/example/v1/example.proto
syntax = "proto3";

package example.v1;

message Greeting {
  string id = 1;
  string content = 2;
  int64 created_at = 3;
  repeated string tags = 4;
  map<string, string> metadata = 5;
}

message CreateGreetingRequest {
  string content = 1;
  repeated string tags = 2;
}

message CreateGreetingResponse {
  Greeting greeting = 1;
}

service GreetingService {
  rpc CreateGreeting(CreateGreetingRequest) returns (CreateGreetingResponse);
  rpc ListGreetings(ListGreetingsRequest) returns (ListGreetingsResponse);
  rpc StreamGreetings(ListGreetingsRequest) returns (stream Greeting);
}
```

### Generated Code Usage

**Standard Protobuf with gRPC:**

```python
import grpc
from proto.gen.python.example.v1 import example_pb2
from proto.gen.python.example.v1 import example_pb2_grpc

# Client usage
async def main():
    # Create channel and stub
    channel = grpc.insecure_channel('localhost:50051')
    stub = example_pb2_grpc.GreetingServiceStub(channel)

    # Create a greeting
    request = example_pb2.CreateGreetingRequest(
        content="Hello from Python!",
        tags=["python", "grpc", "example"]
    )

    response = stub.CreateGreeting(request)
    print(f"Created greeting: {response.greeting.id}")

    # Serialize to bytes
    data = response.greeting.SerializeToString()

    # Deserialize from bytes
    greeting = example_pb2.Greeting()
    greeting.ParseFromString(data)

    # JSON support
    from google.protobuf.json_format import MessageToJson
    json_str = MessageToJson(greeting)
    print(f"JSON: {json_str}")
```

**Server Implementation:**

```python
import grpc
from concurrent import futures
from proto.gen.python.example.v1 import example_pb2
from proto.gen.python.example.v1 import example_pb2_grpc

class GreetingServicer(example_pb2_grpc.GreetingServiceServicer):
    def CreateGreeting(self, request, context):
        greeting = example_pb2.Greeting(
            id=f"greeting-{int(time.time())}",
            content=request.content,
            created_at=int(time.time())
        )
        greeting.tags.extend(request.tags)

        return example_pb2.CreateGreetingResponse(greeting=greeting)

    def StreamGreetings(self, request, context):
        # Stream greetings as they arrive
        while True:
            greeting = example_pb2.Greeting(
                id=f"stream-{int(time.time())}",
                content="Streamed greeting",
                created_at=int(time.time())
            )
            yield greeting
            time.sleep(1)

# Start server
server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
example_pb2_grpc.add_GreetingServiceServicer_to_server(
    GreetingServicer(), server
)
server.add_insecure_port('[::]:50051')
server.start()
server.wait_for_termination()
```

### Try the Example

```bash
cd examples/python-example
nix develop
bufrnix_init
bufrnix
python main.py
pytest -v
```

## JavaScript/TypeScript

**Status**: ✅ Full Support  
**Example**: [`examples/js-example/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/js-example)

JavaScript/TypeScript support provides multiple output formats and RPC options for modern web development.

### Available Plugins

| Plugin                      | Description       | Generated Files        |
| --------------------------- | ----------------- | ---------------------- |
| **`protoc-gen-js`**         | CommonJS messages | `*_pb.js`, `*_pb.d.ts` |
| **`protoc-gen-es`**         | ES modules        | `*.js`, `*.d.ts`       |
| **`protoc-gen-connect-es`** | Connect-ES RPC    | `*_connect.js`         |
| **`protoc-gen-grpc-web`**   | gRPC-Web client   | `*_grpc_web_pb.js`     |
| **`protoc-gen-twirp_js`**   | Twirp RPC         | `*_twirp.js`           |

### Configuration

```nix
languages.js = {
  enable = true;
  outputPath = "src/proto";
  packageName = "@myorg/proto";
  options = [
    "import_style=commonjs"
    "binary"
  ];

  # Modern ECMAScript modules
  es = {
    enable = true;
    options = [
      "target=ts"              # Generate TypeScript
      "import_extension=.js"   # ES module extensions
      "json_types=true"        # JSON type definitions
    ];
  };

  # Connect-ES for type-safe RPC
  connect = {
    enable = true;
    options = [
      "target=ts"
      "import_extension=.js"
    ];
  };

  # gRPC-Web for browser compatibility
  grpcWeb = {
    enable = true;
    options = [
      "import_style=typescript"
      "mode=grpcwebtext"
    ];
  };

  # Twirp RPC framework
  twirp = {
    enable = true;
    options = ["lang=typescript"];
  };
};
```

### Proto Example

```protobuf
// proto/example/v1/example.proto
syntax = "proto3";

package example.v1;

message User {
  string id = 1;
  string name = 2;
  string email = 3;
  int32 age = 4;
}

service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse);
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
}

message GetUserRequest {
  string id = 1;
}

message GetUserResponse {
  User user = 1;
}

message ListUsersRequest {
  int32 page_size = 1;
  string page_token = 2;
}

message ListUsersResponse {
  repeated User users = 1;
  string next_page_token = 2;
}

message CreateUserRequest {
  User user = 1;
}

message CreateUserResponse {
  User user = 1;
}
```

### Generated Code Usage

**ES Modules with Connect-ES (Recommended):**

```typescript
import { UserService } from "./proto/example/v1/example_connect.js";
import { createPromiseClient } from "@connectrpc/connect";
import { createConnectTransport } from "@connectrpc/connect-web";

// Create transport
const transport = createConnectTransport({
  baseUrl: "https://api.example.com",
  credentials: "include",
});

// Create client
const client = createPromiseClient(UserService, transport);

async function main() {
  try {
    // Create a new user
    const createResponse = await client.createUser({
      user: {
        id: "1",
        name: "John Doe",
        email: "john@example.com",
        age: 30,
      },
    });

    console.log("Created user:", createResponse.user);

    // Get the user
    const getResponse = await client.getUser({
      id: "1",
    });

    console.log("Retrieved user:", getResponse.user);

    // List users with pagination
    const listResponse = await client.listUsers({
      pageSize: 10,
      pageToken: "",
    });

    console.log(`Found ${listResponse.users.length} users`);
    console.log("Next page token:", listResponse.nextPageToken);
  } catch (error) {
    console.error("RPC failed:", error);
  }
}

main();
```

### Try the Example

```bash
cd examples/js-example
nix develop
npm install
npm run build
npm start
```

## PHP

**Status**: ✅ Full Support  
**Example**: [`examples/php-twirp/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/php-twirp)

PHP support provides Protocol Buffer messages and Twirp RPC framework integration.

### Available Plugins

| Plugin                     | Description         | Generated Files              |
| -------------------------- | ------------------- | ---------------------------- |
| **`protoc-gen-php`**       | Message classes     | `*.php`, `GPBMetadata/*.php` |
| **`protoc-gen-twirp_php`** | Twirp RPC framework | `*Client.php`, `*Server.php` |

### Configuration

```nix
languages.php = {
  enable = true;
  outputPath = "gen/php";
  namespace = "MyApp\\Proto";
  options = [
    "aggregate_metadata"  # Single metadata file
  ];

  twirp = {
    enable = true;
    options = [
      "generate_client=true"
      "generate_server=true"
    ];
  };
};
```

### Proto Example

```protobuf
// proto/example/v1/service.proto
syntax = "proto3";

package example.v1;

service HelloService {
  rpc Hello(HelloRequest) returns (HelloResponse);
}

message HelloRequest {
  string name = 1;
}

message HelloResponse {
  string greeting = 1;
}
```

### Generated Code Usage

**Twirp Server:**

```php
<?php
require_once 'vendor/autoload.php';

use MyApp\Proto\Example\V1\HelloServiceServer;
use MyApp\Proto\Example\V1\HelloRequest;
use MyApp\Proto\Example\V1\HelloResponse;

class HelloServiceImpl
{
    public function Hello(HelloRequest $request): HelloResponse
    {
        $response = new HelloResponse();
        $response->setGreeting("Hello, " . $request->getName() . "!");
        return $response;
    }
}

// Create and serve
$impl = new HelloServiceImpl();
$server = new HelloServiceServer($impl);

// Handle HTTP request
$server->handle($_SERVER['REQUEST_METHOD'], $_SERVER['REQUEST_URI'], getallheaders(), file_get_contents('php://input'));
```

**Twirp Client:**

```php
<?php
require_once 'vendor/autoload.php';

use MyApp\Proto\Example\V1\HelloServiceClient;
use MyApp\Proto\Example\V1\HelloRequest;

// Create client
$client = new HelloServiceClient('https://api.example.com');

// Make request
$request = new HelloRequest();
$request->setName('World');

try {
    $response = $client->Hello($request);
    echo "Response: " . $response->getGreeting() . "\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
```

### Try the Example

```bash
cd examples/php-twirp
nix develop
composer install
php -S localhost:8080 -t .
```

## C

**Status**: ✅ Full Support  
**Examples**: [`examples/c-protobuf-c/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/c-protobuf-c), [`examples/c-nanopb/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/c-nanopb)

C support provides multiple Protocol Buffer implementations optimized for different use cases, from standard systems to embedded microcontrollers.

### Available Implementations

| Implementation | Description                | Target Use Case                    | Generated Files        |
| -------------- | -------------------------- | ---------------------------------- | ---------------------- |
| **protobuf-c** | Standard C implementation  | General purpose C applications     | `*.pb-c.h`, `*.pb-c.c` |
| **nanopb**     | Lightweight implementation | Embedded systems, microcontrollers | `*.pb.h`, `*.pb.c`     |
| **upb**        | Google's C implementation  | High-performance parsing (future)  | `*.upb.h`, `*.upb.c`   |

### Configuration

```nix
languages.c = {
  enable = true;
  outputPath = "gen/c";

  # Standard C implementation
  protobuf-c = {
    enable = true;
    outputPath = "gen/c/protobuf-c";
    options = [];  # protoc-gen-c options
  };

  # Embedded systems implementation
  nanopb = {
    enable = true;
    outputPath = "gen/c/nanopb";
    options = [];

    # Nanopb-specific configuration
    maxSize = 256;        # Max size for dynamic allocation
    fixedLength = true;   # Use fixed-length arrays
    noUnions = false;     # Allow union (oneof) support
    msgidType = "";       # Message ID type for RPC
  };

  # Google's upb (future support)
  upb = {
    enable = false;  # Not yet available in nixpkgs
    outputPath = "gen/c/upb";
    options = [];
  };
};
```

### Proto Example (protobuf-c)

```protobuf
// proto/example/v1/example.proto
syntax = "proto3";

package example.v1;

message Example {
  string id = 1;
  string name = 2;
  int32 value = 3;
  repeated string tags = 4;
  ExampleType type = 5;
}

enum ExampleType {
  EXAMPLE_TYPE_UNSPECIFIED = 0;
  EXAMPLE_TYPE_BASIC = 1;
  EXAMPLE_TYPE_ADVANCED = 2;
}

message NestedExample {
  Example example = 1;
  map<string, string> metadata = 2;
  bytes data = 3;
}
```

### Generated Code Usage (protobuf-c)

```c
#include "proto/gen/c/protobuf-c/example/v1/example.pb-c.h"
#include <stdio.h>
#include <stdlib.h>

int main() {
    // Create and initialize a message
    Example__V1__Example example = EXAMPLE__V1__EXAMPLE__INIT;
    example.id = "test-123";
    example.name = "Test Example";
    example.value = 42;
    example.type = EXAMPLE__V1__EXAMPLE_TYPE__BASIC;

    // Add tags
    char *tags[] = {"important", "test"};
    example.tags = tags;
    example.n_tags = 2;

    // Serialize the message
    size_t size = example__v1__example__get_packed_size(&example);
    uint8_t *buffer = malloc(size);
    example__v1__example__pack(&example, buffer);

    printf("Serialized %zu bytes\n", size);

    // Deserialize the message
    Example__V1__Example *unpacked =
        example__v1__example__unpack(NULL, size, buffer);

    if (unpacked) {
        printf("Unpacked: %s\n", unpacked->name);
        example__v1__example__free_unpacked(unpacked, NULL);
    }

    free(buffer);
    return 0;
}
```

### Proto Example (nanopb)

```protobuf
// proto/example/v1/sensor.proto
syntax = "proto3";

package sensor.v1;

// Optimized for embedded systems
message SensorReading {
  uint32 timestamp = 1;
  float temperature = 2;
  float humidity = 3;
  uint32 pressure = 4;
  repeated float values = 5;  // Fixed array in nanopb
  SensorStatus status = 6;
}

enum SensorStatus {
  SENSOR_STATUS_UNKNOWN = 0;
  SENSOR_STATUS_OK = 1;
  SENSOR_STATUS_ERROR = 2;
}

message DeviceConfig {
  string device_id = 1;     // Max 32 chars in nanopb
  uint32 sample_rate = 2;
  bool enable_logging = 3;
}
```

### Nanopb Options File

```options
# sensor.options - Constraints for embedded systems
sensor.v1.DeviceConfig.device_id max_size:32
sensor.v1.SensorReading.values max_count:10 fixed_count:true
* type:FT_STATIC  # Use static allocation
```

### Generated Code Usage (nanopb)

```c
#include "proto/gen/c/nanopb/sensor/v1/sensor.pb.h"
#include <pb_encode.h>
#include <pb_decode.h>

bool encode_sensor_reading(uint8_t *buffer, size_t buffer_size, size_t *length) {
    sensor_v1_SensorReading reading = sensor_v1_SensorReading_init_zero;

    // Fill sensor data
    reading.timestamp = 1234567890;
    reading.temperature = 23.5f;
    reading.humidity = 65.2f;
    reading.status = sensor_v1_SensorStatus_SENSOR_STATUS_OK;

    // Fixed array - no dynamic allocation
    reading.values_count = 3;
    reading.values[0] = 1.23f;
    reading.values[1] = 4.56f;
    reading.values[2] = 7.89f;

    // Encode to buffer
    pb_ostream_t stream = pb_ostream_from_buffer(buffer, buffer_size);
    bool status = pb_encode(&stream, sensor_v1_SensorReading_fields, &reading);
    *length = stream.bytes_written;

    return status;
}

bool decode_sensor_reading(const uint8_t *buffer, size_t length) {
    sensor_v1_SensorReading reading = sensor_v1_SensorReading_init_zero;

    pb_istream_t stream = pb_istream_from_buffer(buffer, length);
    bool status = pb_decode(&stream, sensor_v1_SensorReading_fields, &reading);

    if (status) {
        printf("Temperature: %.2f°C\n", reading.temperature);
    }

    return status;
}
```

### Try the Examples

**protobuf-c Example:**

```bash
cd examples/c-protobuf-c
nix build
nix develop
make
./example
```

**nanopb Example:**

```bash
cd examples/c-nanopb
nix build
nix develop
make
./sensor_example
```

### C Implementation Comparison

| Feature                | protobuf-c | nanopb | upb (future) |
| ---------------------- | ---------- | ------ | ------------ |
| **Dynamic Allocation** | ✅         | ❌     | ✅           |
| **Fixed Arrays**       | ❌         | ✅     | ❌           |
| **Code Size**          | Medium     | Small  | Small        |
| **Memory Usage**       | Dynamic    | Static | Arena        |
| **Embedded Systems**   | ⚠️         | ✅     | ⚠️           |
| **Full Proto3**        | ✅         | ⚠️     | ✅           |
| **Services/RPC**       | Basic      | ❌     | ✅           |
| **Extensions**         | ✅         | ❌     | ✅           |
| **Options Files**      | ❌         | ✅     | ❌           |
| **Zero-Copy**          | ❌         | ✅     | ✅           |

### Use Case Guidelines

**Use protobuf-c when:**

- Building standard C applications
- Need full Protocol Buffers compatibility
- Dynamic memory allocation is acceptable
- Integrating with existing C projects

**Use nanopb when:**

- Targeting microcontrollers (Arduino, STM32, etc.)
- Memory is severely constrained (<100KB RAM)
- Need predictable memory usage
- Building real-time systems
- Want zero dynamic allocation

## Swift

**Status**: ✅ Full Support  
**Example**: [`examples/swift-example/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/swift-example)

Swift support provides Protocol Buffer message generation for iOS, macOS, and server applications.

### Available Plugins

| Plugin                 | Description        | Generated Files |
| ---------------------- | ------------------ | --------------- |
| **`protoc-gen-swift`** | Message generation | `*.pb.swift`    |

### Configuration

```nix
languages.swift = {
  enable = true;
  outputPath = "Sources/Generated";
  packageName = "MyAppProto";
  options = [
    "Visibility=Public"              # Make generated types public
    "FileNaming=PathToUnderscores"   # Use underscores in file names
  ];
};
```

### Proto Example

```protobuf
// proto/example/v1/example.proto
syntax = "proto3";

package example.v1;

message Example {
  string id = 1;
  string name = 2;
  int32 value = 3;
}

service ExampleService {
  rpc GetExample(GetExampleRequest) returns (GetExampleResponse);
}

message GetExampleRequest {
  string id = 1;
}

message GetExampleResponse {
  Example example = 1;
}
```

### Generated Code Usage

```swift
import Foundation
import SwiftProtobuf

// Import generated code
// import Example_V1

// Create an Example message
var example = Example_V1_Example()
example.id = "123"
example.name = "Test Example"
example.value = 42

// Serialize to binary
let binaryData = try example.serializedData()
print("Serialized binary size: \(binaryData.count) bytes")

// Serialize to JSON
let jsonData = try example.jsonUTF8Data()
if let jsonString = String(data: jsonData, encoding: .utf8) {
    print("JSON representation:")
    print(jsonString)
}

// Deserialize from binary
let decodedExample = try Example_V1_Example(serializedData: binaryData)
print("Decoded example: \(decodedExample.name)")

// Create a service request
var request = Example_V1_GetExampleRequest()
request.id = "123"

// Create a service response
var response = Example_V1_GetExampleResponse()
response.example = example

print("\nExample message created successfully!")
print("ID: \(example.id)")
print("Name: \(example.name)")
print("Value: \(example.value)")
```

### Try the Example

```bash
cd examples/swift-example
nix develop
bufrnix_init
bufrnix
swift build
swift run
```

## Language Comparison

| Feature              | Go  | Dart | JavaScript/TypeScript | PHP | Python | Swift | C (protobuf-c) | C (nanopb) |
| -------------------- | --- | ---- | --------------------- | --- | ------ | ----- | -------------- | ---------- |
| **Base Messages**    | ✅  | ✅   | ✅                    | ✅  | ✅     | ✅    | ✅             | ✅         |
| **gRPC Services**    | ✅  | ✅   | ✅ (Web)              | ❌  | ✅     | ❌    | ⚠️ (Basic)     | ❌         |
| **Streaming RPC**    | ✅  | ✅   | ✅ (Web)              | ❌  | ✅     | ❌    | ❌             | ❌         |
| **HTTP Gateway**     | ✅  | ❌   | ❌                    | ❌  | ❌     | ❌    | ❌             | ❌         |
| **Validation**       | ✅  | ❌   | ❌                    | ❌  | ❌     | ❌    | ❌             | ❌         |
| **Connect Protocol** | ✅  | ❌   | ✅                    | ❌  | ❌     | ❌    | ❌             | ❌         |
| **Twirp RPC**        | ❌  | ❌   | ✅                    | ✅  | ❌     | ❌    | ❌             | ❌         |
| **JSON Mapping**     | ✅  | ✅   | ✅                    | ✅  | ✅     | ✅    | ❌             | ❌         |
| **Type Safety**      | ✅  | ✅   | ✅                    | ⚠️  | ✅     | ✅    | ⚠️             | ⚠️         |
| **Server Support**   | ✅  | ✅   | ❌                    | ✅  | ✅     | ✅    | ✅             | ✅         |
| **Browser Support**  | ❌  | ❌   | ✅                    | ❌  | ❌     | ❌    | ❌             | ❌         |
| **Codable Support**  | ❌  | ❌   | ❌                    | ❌  | ❌     | ✅    | ❌             | ❌         |
| **Dynamic Memory**   | ✅  | ✅   | ✅                    | ✅  | ✅     | ✅    | ✅             | ❌         |
| **Embedded Systems** | ❌  | ❌   | ❌                    | ❌  | ❌     | ❌    | ⚠️             | ✅         |
| **Zero Allocation**  | ❌  | ❌   | ❌                    | ❌  | ❌     | ❌    | ❌             | ✅         |
| **Type Stubs**       | ❌  | ❌   | ✅                    | ❌  | ✅     | ❌    | ❌             | ❌         |
| **Async Support**    | ✅  | ✅   | ✅                    | ❌  | ✅     | ✅    | ❌             | ❌         |

## Multi-Language Projects

Generate code for multiple languages simultaneously:

```nix
config = {
  root = ./.;
  protoc = {
    sourceDirectories = ["./proto"];
    includeDirectories = ["./proto"];
  };

  # Backend in Go
  languages.go = {
    enable = true;
    outputPath = "backend/gen/go";
    grpc.enable = true;
    gateway.enable = true;
  };

  # Mobile app in Dart
  languages.dart = {
    enable = true;
    outputPath = "mobile/lib/proto";
    grpc.enable = true;
  };

  # Web frontend in TypeScript
  languages.js = {
    enable = true;
    outputPath = "web/src/proto";
    es.enable = true;
    connect.enable = true;
  };

  # Legacy services in PHP
  languages.php = {
    enable = true;
    outputPath = "legacy/gen/php";
    twirp.enable = true;
  };

  # Data processing in Python
  languages.python = {
    enable = true;
    outputPath = "analytics/gen/python";
    grpc.enable = true;
    mypy.enable = true;
  };

  # iOS/macOS app in Swift
  languages.swift = {
    enable = true;
    outputPath = "ios/Sources/Generated";
    packageName = "AppProto";
  };

  # Embedded devices in C
  languages.c = {
    enable = true;
    outputPath = "embedded/gen/c";

    # Standard C for Linux gateways
    protobuf-c = {
      enable = true;
    };

    # Microcontroller firmware
    nanopb = {
      enable = true;
      maxSize = 128;
      fixedLength = true;
    };
  };
};
```

## Examples Repository

All examples are available in the [`examples/`](https://github.com/conneroisu/bufr.nix/tree/main/examples) directory:

- **`simple-flake/`** - Go gRPC server/client with complex message types
- **`dart-example/`** - Comprehensive Dart protobuf usage with testing
- **`js-example/`** - Multiple JavaScript output formats and RPC options
- **`php-twirp/`** - PHP Twirp RPC server and client implementation
- **`python-example/`** - Python protobuf with gRPC, type stubs, and mypy integration
- **`swift-example/`** - Swift Protocol Buffers with SwiftProtobuf integration
- **`c-protobuf-c/`** - Standard C implementation with protobuf-c
- **`c-nanopb/`** - Embedded C implementation with nanopb for microcontrollers

Each example includes detailed README files with setup instructions and usage patterns.

## Adding New Languages

To add support for a new language, see the [Language Modules Development Guide](../../../src/languages/README.md#adding-a-new-language-module).

## Troubleshooting

For language-specific issues, see the [Troubleshooting Guide](../guides/troubleshooting.md).
