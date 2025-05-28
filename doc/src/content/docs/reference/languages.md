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
**Examples**:

- [`examples/js-es-modules/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/js-es-modules) - Modern TypeScript with Protobuf-ES and Connect-ES
- [`examples/js-grpc-web/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/js-grpc-web) - Browser gRPC with gRPC-Web
- [`examples/js-protovalidate/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/js-protovalidate) - Runtime validation example

JavaScript and TypeScript support in bufrnix provides a modern, TypeScript-first development experience with multiple code generation options.

### Available Plugins

| Plugin                    | Description                        | Generated Files          |
| ------------------------- | ---------------------------------- | ------------------------ |
| **`protoc-gen-es`**       | Modern TypeScript/JS (recommended) | `*.ts`, `*.js`, `*.d.ts` |
| **`protoc-gen-js`**       | Legacy CommonJS (deprecated)       | `*_pb.js`                |
| **`protoc-gen-grpc-web`** | gRPC-Web for browsers              | `*_grpc_web_pb.js`       |
| **`ts-proto`**            | Alternative TypeScript generator   | `*.ts` (interfaces)      |

Note: Connect-ES functionality is now integrated into protoc-gen-es v2.

### Configuration

```nix
languages = {
  js = {
    enable = true;
    outputPath = "gen/js";

    # Protobuf-ES - The default TypeScript generator (recommended)
    es = {
      enable = true;  # Enabled by default
      target = "ts";  # Options: "js", "ts", "dts"
      generatePackageJson = true;
      packageName = "@myproject/proto";
      importExtension = ".js";  # For Node.js ES modules
    };

    # Connect-ES - Modern RPC framework
    connect = {
      enable = true;  # Integrated with protoc-gen-es v2
      generatePackageJson = true;
      packageName = "@myproject/connect";
    };

    # Runtime validation support
    protovalidate = {
      enable = true;
      generateValidationHelpers = true;
    };

    # Alternative: ts-proto for different style
    tsProto = {
      enable = false;  # Set to true for interface-style TypeScript
      generatePackageJson = true;
      generateTsConfig = true;
      options = [
        "esModuleInterop=true"
        "outputServices=nice-grpc"
        "useOptionals=messages"
      ];
    };

    # Legacy options
    grpcWeb = {
      enable = false;  # For browser gRPC support
    };
  };
};
```

### Generated Code Features

#### Protobuf-ES (Default)

- **Full TypeScript Support**: Type-safe message creation and serialization
- **ES Modules**: Modern JavaScript with optimal tree-shaking
- **Conformant Implementation**: Only fully conformant JavaScript protobuf library
- **Schema-based API**: Clean `create()`, `toBinary()`, `toJson()` functions
- **Connect Integration**: Services generated alongside messages with v2

#### Connect-ES

- **Modern RPC**: Supports Connect, gRPC, and gRPC-Web protocols
- **Type-safe Clients**: Full TypeScript support for service methods
- **Streaming Support**: Server and client streaming capabilities
- **Browser Compatible**: Works in Node.js and browsers

#### Protovalidate

- **Runtime Validation**: Enforce protobuf constraints at runtime
- **buf.validate Support**: Compatible with buf.build validation rules
- **TypeScript Integration**: Type-safe validation errors

#### ts-proto (Alternative)

- **Interface Style**: Generates TypeScript interfaces instead of classes
- **Customizable**: Extensive options for code generation
- **Popular Choice**: Widely used in the TypeScript community

### Example Usage

```typescript
// Using Protobuf-ES (default)
import { User, Role } from "./gen/js/user_pb.js";
import { UserService } from "./gen/js/user_connect.js";
import { createPromiseClient } from "@connectrpc/connect";

// Create a message
const user = new User({
  id: "123",
  email: "user@example.com",
  name: "John Doe",
  role: Role.USER,
});

// Serialize
const bytes = user.toBinary();
const json = user.toJson();

// Create a client
const client = createPromiseClient(UserService, transport);
const response = await client.createUser({ user });

// Validate
import { createValidator } from "@bufbuild/protovalidate";
const validator = await createValidator();
const violations = await validator.validate(user);
```

### Try the Example

```bash
cd examples/js-es-modules
nix build
npm install
npm run server  # In one terminal
npm run client  # In another terminal
```

## PHP

**Status**: ✅ Full Support  
**Examples**: [`examples/php-grpc-roadrunner/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/php-grpc-roadrunner), [`examples/php-twirp/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/php-twirp)

PHP support provides comprehensive Protocol Buffer and gRPC development with high-performance server options and modern async patterns.

### Available Plugins

| Plugin                     | Description              | Generated Files                 |
| -------------------------- | ------------------------ | ------------------------------- |
| **`protoc-gen-php`**       | Message classes          | `*.php`, `GPBMetadata/*.php`    |
| **`grpc_php_plugin`**      | gRPC client/server stubs | `*Client.php`, `*Interface.php` |
| **`protoc-gen-twirp_php`** | Twirp RPC (deprecated)   | `*Client.php`, `*Server.php`    |

### Configuration

```nix
languages.php = {
  enable = true;
  outputPath = "gen/php";

  # Namespace configuration
  namespace = "App\\Proto";
  metadataNamespace = "GPBMetadata";
  classPrefix = "";  # Optional prefix

  # Composer integration
  composer = {
    enable = true;
    autoInstall = false;
  };

  # gRPC support
  grpc = {
    enable = true;
    serviceNamespace = "Services";
    clientOnly = false;
  };

  # High-performance RoadRunner server
  roadrunner = {
    enable = true;
    workers = 4;
    maxJobs = 100;
    maxMemory = 128;
    tlsEnabled = false;
  };

  # Framework integration
  frameworks = {
    laravel = {
      enable = false;
      serviceProvider = true;
      artisanCommands = true;
    };

    symfony = {
      enable = false;
      bundle = true;
      messengerIntegration = true;
    };
  };

  # Async PHP support
  async = {
    reactphp = {
      enable = false;
      version = "^1.0";
    };

    swoole = {
      enable = false;
      coroutines = true;
    };

    fibers = {
      enable = false;  # PHP 8.1+
    };
  };
};
```

### Proto Example

```protobuf
// proto/example/v1/service.proto
syntax = "proto3";

package example.v1;

option php_namespace = "App\\Proto\\Example\\V1";
option php_metadata_namespace = "App\\Proto\\Metadata\\Example\\V1";

service GreeterService {
  // Unary RPC
  rpc SayHello (HelloRequest) returns (HelloResponse);

  // Server streaming RPC
  rpc SayHelloStream (HelloRequest) returns (stream HelloResponse);

  // Client streaming RPC
  rpc SayHelloClientStream (stream HelloRequest) returns (HelloResponse);

  // Bidirectional streaming RPC
  rpc SayHelloBidirectional (stream HelloRequest) returns (stream HelloResponse);
}

message HelloRequest {
  string name = 1;
  int32 count = 2;
  map<string, string> metadata = 3;
}

message HelloResponse {
  string message = 1;
  int64 timestamp = 2;
  bool success = 3;
}
```

### Generated Code Usage

**gRPC Client:**

```php
<?php
use App\Proto\Example\V1\HelloRequest;
use App\Proto\Example\V1\Services\GreeterServiceClient;
use Grpc\ChannelCredentials;

// Create client
$client = new GreeterServiceClient('localhost:9001', [
    'credentials' => ChannelCredentials::createInsecure(),
]);

// Unary call
$request = new HelloRequest();
$request->setName('Bufrnix');
[$response, $status] = $client->SayHello($request)->wait();

if ($status->code === \Grpc\STATUS_OK) {
    echo $response->getMessage();
}

// Server streaming
$call = $client->SayHelloStream($request);
foreach ($call->responses() as $response) {
    echo $response->getMessage() . "\n";
}
```

**RoadRunner Server:**

```php
<?php
// worker.php
use Spiral\RoadRunner\GRPC\Server;
use Spiral\RoadRunner\Worker;
use App\Services\GreeterService;
use App\Proto\Example\V1\Services\GreeterServiceInterface;

require __DIR__ . '/vendor/autoload.php';

$server = new Server();
$server->registerService(
    GreeterServiceInterface::class,
    new GreeterService()
);

$server->serve(Worker::create());
```

**Service Implementation:**

```php
<?php
use App\Proto\Example\V1\HelloRequest;
use App\Proto\Example\V1\HelloResponse;
use App\Proto\Example\V1\Services\GreeterServiceInterface;
use Spiral\RoadRunner\GRPC\ContextInterface;

class GreeterService implements GreeterServiceInterface
{
    public function SayHello(
        ContextInterface $ctx,
        HelloRequest $request
    ): HelloResponse {
        $response = new HelloResponse();
        $response->setMessage("Hello, " . $request->getName() . "!");
        $response->setTimestamp(time());
        $response->setSuccess(true);

        return $response;
    }

    public function SayHelloStream(
        ContextInterface $ctx,
        HelloRequest $request
    ): \Generator {
        for ($i = 0; $i < $request->getCount(); $i++) {
            $response = new HelloResponse();
            $response->setMessage("Stream #$i: Hello, " . $request->getName());
            $response->setTimestamp(time());

            yield $response;
            usleep(500000); // 500ms delay
        }
    }
}
```

### Framework Integration

**Laravel:**

```php
// app/Http/Controllers/GreeterController.php
public function greet(Request $request, GreeterServiceClient $client)
{
    $grpcRequest = new HelloRequest();
    $grpcRequest->setName($request->input('name'));

    [$response, $status] = $client->SayHello($grpcRequest)->wait();

    return response()->json([
        'message' => $response->getMessage(),
    ]);
}
```

**Symfony:**

```php
// src/Controller/GreeterController.php
#[Route('/greet/{name}')]
public function greet(string $name, GreeterServiceClient $client): JsonResponse
{
    $request = new HelloRequest();
    $request->setName($name);

    [$response, $status] = $client->SayHello($request)->wait();

    return $this->json([
        'message' => $response->getMessage(),
    ]);
}
```

### Async PHP Examples

**ReactPHP:**

```php
use App\Proto\Async\ReactPHPClient;

$client = new ReactPHPClient('localhost:9001');
$client->sendRequestAsync($request)->then(
    function ($response) {
        echo "Async: " . $response->getMessage();
    }
);
$client->run();
```

**Swoole:**

```php
use App\Proto\Async\SwooleGrpcServer;

$server = new SwooleGrpcServer('0.0.0.0', 9501);
$server->registerService(GreeterServiceInterface::class, new GreeterService());
$server->start();
```

**PHP Fibers (8.1+):**

```php
use App\Proto\Async\FiberProtobufHandler;

$handler = new FiberProtobufHandler();
$results = $handler->processConcurrent([
    'req1' => $request1->serializeToString(),
    'req2' => $request2->serializeToString(),
]);
```

### Try the Examples

**gRPC + RoadRunner:**

```bash
cd examples/php-grpc-roadrunner
nix develop
composer install
./roadrunner-dev.sh start
php test-client.php
```

**Legacy Twirp:**

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
| **Validation**       | ✅  | ❌   | ✅                    | ❌  | ❌     | ❌    | ❌             | ❌         |
| **Connect Protocol** | ✅  | ❌   | ✅                    | ❌  | ❌     | ❌    | ❌             | ❌         |
| **Twirp RPC**        | ❌  | ❌   | ✅                    | ✅  | ❌     | ❌    | ❌             | ❌         |
| **JSON Mapping**     | ✅  | ✅   | ✅                    | ✅  | ✅     | ✅    | ❌             | ❌         |
| **Type Safety**      | ✅  | ✅   | ✅                    | ⚠️  | ✅     | ✅    | ⚠️             | ⚠️         |
| **Server Support**   | ✅  | ✅   | ✅                    | ✅  | ✅     | ✅    | ✅             | ✅         |
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

  # Backend services in PHP
  languages.php = {
    enable = true;
    outputPath = "backend/gen/php";
    namespace = "Backend\\Proto";

    grpc.enable = true;
    roadrunner = {
      enable = true;
      workers = 8;
    };

    frameworks.laravel.enable = true;
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
- **`js-es-modules/`** - Modern TypeScript with Protobuf-ES and Connect-ES
- **`js-grpc-web/`** - Browser gRPC communication
- **`js-protovalidate/`** - JavaScript/TypeScript with protovalidate-es runtime validation
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
