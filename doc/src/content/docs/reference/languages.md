---
title: Language Support
description: Complete guide to all languages supported by Bufrnix with examples and configuration options.
---

# Language Support

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

| Plugin | Description | Generated Files |
|--------|-------------|-----------------|
| **`protoc-gen-go`** | Base message generation | `*.pb.go` |
| **`protoc-gen-go-grpc`** | gRPC services | `*_grpc.pb.go` |
| **`protoc-gen-connect-go`** | Connect protocol | `*_connect.go` |
| **`protoc-gen-grpc-gateway`** | HTTP/JSON gateway | `*.pb.gw.go` |
| **`protoc-gen-validate`** | Message validation | `*.pb.validate.go` |

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

| Plugin | Description | Generated Files |
|--------|-------------|-----------------|
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

## JavaScript/TypeScript

**Status**: ✅ Full Support  
**Example**: [`examples/js-example/`](https://github.com/conneroisu/bufr.nix/tree/main/examples/js-example)

JavaScript/TypeScript support provides multiple output formats and RPC options for modern web development.

### Available Plugins

| Plugin | Description | Generated Files |
|--------|-------------|-----------------|
| **`protoc-gen-js`** | CommonJS messages | `*_pb.js`, `*_pb.d.ts` |
| **`protoc-gen-es`** | ES modules | `*.js`, `*.d.ts` |
| **`protoc-gen-connect-es`** | Connect-ES RPC | `*_connect.js` |
| **`protoc-gen-grpc-web`** | gRPC-Web client | `*_grpc_web_pb.js` |
| **`protoc-gen-twirp_js`** | Twirp RPC | `*_twirp.js` |

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
import { UserService } from './proto/example/v1/example_connect.js';
import { createPromiseClient } from '@connectrpc/connect';
import { createConnectTransport } from '@connectrpc/connect-web';

// Create transport
const transport = createConnectTransport({
  baseUrl: 'https://api.example.com',
  credentials: 'include',
});

// Create client
const client = createPromiseClient(UserService, transport);

async function main() {
  try {
    // Create a new user
    const createResponse = await client.createUser({
      user: {
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        age: 30,
      },
    });
    
    console.log('Created user:', createResponse.user);
    
    // Get the user
    const getResponse = await client.getUser({
      id: '1',
    });
    
    console.log('Retrieved user:', getResponse.user);
    
    // List users with pagination
    const listResponse = await client.listUsers({
      pageSize: 10,
      pageToken: '',
    });
    
    console.log(`Found ${listResponse.users.length} users`);
    console.log('Next page token:', listResponse.nextPageToken);
    
  } catch (error) {
    console.error('RPC failed:', error);
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

| Plugin | Description | Generated Files |
|--------|-------------|-----------------|
| **`protoc-gen-php`** | Message classes | `*.php`, `GPBMetadata/*.php` |
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

## Language Comparison

| Feature | Go | Dart | JavaScript/TypeScript | PHP |
|---------|----|----|---------------------|-----|
| **Base Messages** | ✅ | ✅ | ✅ | ✅ |
| **gRPC Services** | ✅ | ✅ | ✅ (Web) | ❌ |
| **Streaming RPC** | ✅ | ✅ | ✅ (Web) | ❌ |
| **HTTP Gateway** | ✅ | ❌ | ❌ | ❌ |
| **Validation** | ✅ | ❌ | ❌ | ❌ |
| **Connect Protocol** | ✅ | ❌ | ✅ | ❌ |
| **Twirp RPC** | ❌ | ❌ | ✅ | ✅ |
| **JSON Mapping** | ✅ | ✅ | ✅ | ✅ |
| **Type Safety** | ✅ | ✅ | ✅ | ⚠️ |
| **Server Support** | ✅ | ✅ | ❌ | ✅ |
| **Browser Support** | ❌ | ❌ | ✅ | ❌ |

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
};
```

## Examples Repository

All examples are available in the [`examples/`](https://github.com/conneroisu/bufr.nix/tree/main/examples) directory:

- **`simple-flake/`** - Go gRPC server/client with complex message types
- **`dart-example/`** - Comprehensive Dart protobuf usage with testing
- **`js-example/`** - Multiple JavaScript output formats and RPC options
- **`php-twirp/`** - PHP Twirp RPC server and client implementation

Each example includes detailed README files with setup instructions and usage patterns.

## Adding New Languages

To add support for a new language, see the [Language Modules Development Guide](../../../src/languages/README.md#adding-a-new-language-module).

## Troubleshooting

For language-specific issues, see the [Troubleshooting Guide](../guides/troubleshooting.md).