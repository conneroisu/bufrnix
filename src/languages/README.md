# Bufrnix Language Modules

This directory contains language modules for Bufrnix. Each language module provides the necessary configuration and implementation for generating code for a specific programming language using Protocol Buffers.

## Overview

Bufrnix supports a rich ecosystem of Protocol Buffer plugins and code generators through modular language implementations. Each language module is designed to be:

- **Self-contained**: All dependencies and configuration managed within the module
- **Configurable**: Extensive options for customizing code generation
- **Composable**: Can be used together in multi-language projects
- **Reproducible**: Deterministic builds through Nix package management

## Supported Languages

### Go

**Location**: `src/languages/go/`

Go support includes the complete Protocol Buffer ecosystem with modern tooling and performance optimizations.

#### Available Plugins

##### Core Plugins

- **`default.nix`** - Base Protocol Buffer message generation (`protoc-gen-go`)
- **`grpc.nix`** - gRPC service generation (`protoc-gen-go-grpc`)
- **`connect.nix`** - Connect-Go protocol support (`protoc-gen-connect-go`)
- **`gateway.nix`** - gRPC-Gateway for HTTP/JSON transcoding (`protoc-gen-grpc-gateway`)

##### Validation Plugins

- **`validate.nix`** - Legacy message validation (`protoc-gen-validate`)
- **`protovalidate.nix`** - Modern CEL-based validation (`protovalidate-go`)

##### Performance & Feature Plugins

- **`vtprotobuf.nix`** - High-performance serialization (`protoc-gen-go-vtproto`) - 3.8x faster
- **`json.nix`** - JSON integration with `encoding/json` (`protoc-gen-go-json`)
- **`federation.nix`** - gRPC Federation for BFF servers (`protoc-gen-grpc-federation`)

#### Buf Registry Plugin Support

Bufrnix supports using Buf registry plugin names directly:

```nix
languages.go = {
  enable = true;
  plugins = [
    "buf.build/protocolbuffers/go"
    "buf.build/grpc/go"
    {
      plugin = "buf.build/community/planetscale-vtprotobuf";
      opt = ["features=marshal+unmarshal+size+pool"];
    }
    "buf.build/community/mfridman-go-json"
    "buf.build/bufbuild/validate-go"
  ];
};
```

#### Configuration Example

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

  # HTTP/JSON gateway
  gateway = {
    enable = true;
    options = [
      "paths=source_relative"
      "generate_unbound_methods=true"
      "allow_delete_body=true"
    ];
  };

  # Modern validation (recommended over validate)
  protovalidate = {
    enable = true;
  };

  # Legacy validation (use protovalidate for new projects)
  validate = {
    enable = true;
    options = ["lang=go"];
  };

  # Modern Connect protocol
  connect = {
    enable = true;
    options = ["paths=source_relative"];
  };

  # High-performance serialization
  vtprotobuf = {
    enable = true;
    options = [
      "paths=source_relative"
      "features=marshal+unmarshal+size+pool"
    ];
  };

  # JSON integration
  json = {
    enable = true;
    options = ["paths=source_relative" "orig_name=true"];
  };

  # gRPC Federation (experimental)
  federation = {
    enable = true;
    options = ["paths=source_relative"];
  };
};
```

#### Generated Files

For a proto file `user/v1/user.proto`:

- `user.pb.go` - Protocol Buffer messages
- `user_grpc.pb.go` - gRPC service interfaces (if grpc.enable = true)
- `user.pb.gw.go` - HTTP gateway handlers (if gateway.enable = true)
- `user.pb.validate.go` - Legacy validation functions (if validate.enable = true)
- `user_connect.go` - Connect service definitions (if connect.enable = true)
- `user_vtproto.pb.go` - High-performance marshal/unmarshal (if vtprotobuf.enable = true)
- `user.pb.json.go` - JSON marshal/unmarshal methods (if json.enable = true)
- `user_federation.pb.go` - Federation BFF code (if federation.enable = true)

### C++

**Location**: `src/languages/cpp/`

C++ support provides comprehensive Protocol Buffer and gRPC integration with modern C++ features, CMake integration, and high-performance optimizations.

#### Available Plugins

##### Core Plugins

- **`default.nix`** - Base Protocol Buffer message generation (built-in `protoc` C++ generator)
- **`grpc.nix`** - gRPC service generation (`grpc_cpp_plugin`)
- **`cmake.nix`** - CMake integration and build support

##### Alternative Implementations

- **`nanopb.nix`** - Ultra-lightweight C implementation for embedded systems
- **`protobuf-c.nix`** - Pure C implementation for system programming
- **`plugins.nix`** - FlatBuffers support for zero-copy serialization

#### Configuration Example

```nix
languages.cpp = {
  enable = true;
  protobufVersion = "latest";  # or "3.21", "3.25", "3.27", "4.25", "5.29"
  standard = "c++20";          # or "c++17", "c++23"
  optimizeFor = "SPEED";       # or "CODE_SIZE", "LITE_RUNTIME"
  runtime = "full";            # or "lite"
  outputPath = "gen/cpp";

  # Performance optimizations
  arenaAllocation = true;      # Enable arena allocation for better performance

  # Build system integration
  cmakeIntegration = true;     # Generate CMake integration files
  pkgConfigIntegration = true; # Generate pkg-config files

  # Additional include paths
  includePaths = [
    "/usr/local/include"
    "third_party/include"
  ];

  options = [
    "paths=source_relative"
    "annotate_headers"
  ];

  # gRPC service generation
  grpc = {
    enable = true;
    generateMockCode = true;   # Generate mock classes for testing
    options = [
      "paths=source_relative"
      "services_namespace=rpc"
    ];
  };

  # Embedded C/C++ with nanopb
  nanopb = {
    enable = false;
    options = [
      "max_size=1024"
      "max_count=16"
    ];
  };

  # Pure C implementation
  protobuf-c = {
    enable = false;
    options = [];
  };
};
```

#### Generated Files

For a proto file `user/v1/user.proto`:

- `user.pb.h` - C++ message class declarations
- `user.pb.cc` - C++ message class implementations
- `user.grpc.pb.h` - gRPC service declarations (if grpc.enable = true)
- `user.grpc.pb.cc` - gRPC service implementations (if grpc.enable = true)
- `cmake/modules/FindBufrnixProto.cmake` - CMake integration (if cmakeIntegration = true)
- `cmake/modules/BufrnixHelpers.cmake` - CMake helper functions

#### CMake Integration

Bufrnix generates CMake modules for seamless integration:

```cmake
# In your CMakeLists.txt
find_package(BufrnixProto REQUIRED)
include(BufrnixHelpers)

# Collect generated sources automatically
bufrnix_collect_proto_sources(PROTO_SOURCES)

# Create executable with protobuf support
bufrnix_add_proto_executable(my_app
  SOURCES src/main.cpp src/app.cpp
  PROTO_SOURCES ${PROTO_SOURCES}
)

# Enable modern C++ features and optimizations
bufrnix_enable_cpp_features(my_app)
```

#### Integration Examples

**Basic Protobuf Usage:**

```cpp
#include "user.pb.h"
#include <google/protobuf/util/json_util.h>

// Create and populate message
User user;
user.set_name("John Doe");
user.set_email("john@example.com");

// Serialize to binary
std::string binary_data;
user.SerializeToString(&binary_data);

// Serialize to JSON
std::string json_data;
google::protobuf::util::MessageToJsonString(user, &json_data);
```

**gRPC Service Implementation:**

```cpp
#include "user.grpc.pb.h"
#include <grpcpp/grpcpp.h>

class UserServiceImpl : public UserService::Service {
public:
  Status GetUser(ServerContext* context,
                 const GetUserRequest* request,
                 GetUserResponse* response) override {
    // Implementation
    return Status::OK;
  }
};

// Client usage
auto channel = grpc::CreateChannel("localhost:50051",
                                   grpc::InsecureChannelCredentials());
auto stub = UserService::NewStub(channel);
```

#### Performance Features

- **Arena Allocation**: Automatic memory pooling for high-throughput scenarios
- **C++17/20/23 Support**: Modern language features and optimizations
- **Lite Runtime**: Reduced memory footprint for resource-constrained environments
- **Zero-Copy Operations**: With FlatBuffers alternative
- **Optimized Generated Code**: Speed or size optimization modes

#### Supported Protobuf Versions

- **Latest (5.29+)**: Full feature support with modern C++
- **4.25**: Stable release with Abseil dependency
- **3.27**: LTS release with broad compatibility
- **3.25**: Legacy support for older systems
- **3.21**: Minimum supported version

### Dart

**Location**: `src/languages/dart/`

Dart support provides complete Protocol Buffer and gRPC integration for Flutter and server applications.

#### Available Plugins

- **`default.nix`** - Base Protocol Buffer message generation (`protoc-gen-dart`)
- **`grpc.nix`** - gRPC client and server generation

#### Configuration Example

```nix
languages.dart = {
  enable = true;
  outputPath = "lib/proto";
  packageName = "my_app_proto";
  options = [
    "generate_kythe_info"  # Generate metadata for IDE support
  ];

  # gRPC support
  grpc = {
    enable = true;
    options = [
      "generate_metadata"
    ];
  };
};
```

#### Generated Files

For a proto file `user/v1/user.proto`:

- `user.pb.dart` - Protocol Buffer message classes
- `user.pbenum.dart` - Enum definitions
- `user.pbjson.dart` - JSON serialization support
- `user.pbgrpc.dart` - gRPC client and server stubs (if grpc.enable = true)

#### Integration Example

```dart
import 'package:grpc/grpc.dart';
import 'lib/proto/user/v1/user.pbgrpc.dart';

// Create gRPC client
final channel = ClientChannel('localhost', port: 50051);
final client = UserServiceClient(channel);

// Make RPC call
final request = GetUserRequest()..id = 'user123';
final response = await client.getUser(request);

print('User: ${response.user.name}');
```

### JavaScript/TypeScript

**Location**: `src/languages/js/`

JavaScript support provides multiple output formats and RPC options for modern web development.

#### Available Plugins

- **`default.nix`** - Standard JavaScript generation (`protoc-gen-js`)
- **`grpc-web.nix`** - Browser-compatible gRPC (`protoc-gen-grpc-web`)
- **`twirp.nix`** - Twirp RPC framework (`protoc-gen-twirp_js`)

Note: ES modules and Connect-ES support are built into the default module.

#### Configuration Example

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
      "target=ts"                    # Generate TypeScript
      "import_extension=.js"         # ES module extensions
      "json_types=true"              # JSON type definitions
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
      "format=text"
    ];
  };

  # Twirp RPC framework
  twirp = {
    enable = true;
    options = ["lang=typescript"];
  };
};
```

#### Generated Files

For a proto file `user/v1/user.proto`:

- `user_pb.js` - CommonJS Protocol Buffer messages
- `user_pb.d.ts` - TypeScript definitions
- `user.js` - ES module format (if es.enable = true)
- `user_connect.js` - Connect-ES client (if connect.enable = true)
- `user_grpc_web_pb.js` - gRPC-Web client (if grpcWeb.enable = true)
- `user_twirp.js` - Twirp client (if twirp.enable = true)

#### Integration Examples

**ES Modules with Connect-ES:**

```typescript
import { UserService } from "./proto/user/v1/user_connect.js";
import { createPromiseClient } from "@connectrpc/connect";
import { createConnectTransport } from "@connectrpc/connect-web";

const transport = createConnectTransport({
  baseUrl: "https://api.example.com",
});

const client = createPromiseClient(UserService, transport);

const response = await client.getUser({ id: "user123" });
console.log(`User: ${response.user?.name}`);
```

**gRPC-Web:**

```typescript
import { UserServiceClient } from "./proto/user/v1/user_grpc_web_pb";
import { GetUserRequest } from "./proto/user/v1/user_pb";

const client = new UserServiceClient("https://api.example.com");

const request = new GetUserRequest();
request.setId("user123");

client.getUser(request, {}, (err, response) => {
  if (err) {
    console.error(err);
  } else {
    console.log(`User: ${response.getUser()?.getName()}`);
  }
});
```

### PHP

**Location**: `src/languages/php/`

PHP support provides Protocol Buffer messages and Twirp RPC framework integration.

#### Available Plugins

- **`default.nix`** - Standard PHP message generation (`protoc-gen-php`)
- **`twirp.nix`** - Twirp RPC framework (`protoc-gen-twirp_php`)

#### Configuration Example

```nix
languages.php = {
  enable = true;
  outputPath = "gen/php";
  namespace = "MyApp\\Proto";
  options = [
    "aggregate_metadata"  # Single metadata file
  ];

  # Twirp RPC support
  twirp = {
    enable = true;
    options = [
      "generate_client=true"
      "generate_server=true"
    ];
  };
};
```

#### Generated Files

For a proto file `user/v1/user.proto`:

- `User/V1/User.php` - Message classes
- `User/V1/UserService.php` - Service interface (if twirp.enable = true)
- `User/V1/UserServiceClient.php` - Twirp client (if twirp.enable = true)
- `User/V1/UserServiceServer.php` - Twirp server (if twirp.enable = true)
- `GPBMetadata/User/V1/User.php` - Metadata

#### Integration Example

```php
<?php
require_once 'vendor/autoload.php';

use MyApp\Proto\User\V1\UserServiceClient;
use MyApp\Proto\User\V1\GetUserRequest;

$client = new UserServiceClient('https://api.example.com');

$request = new GetUserRequest();
$request->setId('user123');

try {
    $response = $client->GetUser($request);
    echo "User: " . $response->getUser()->getName() . "\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
```

### Documentation

**Location**: `src/languages/doc/`

Documentation support provides generated documentation from Protocol Buffer files in various formats.

#### Available Plugins

- **`default.nix`** - Documentation generation (`protoc-gen-doc`)

#### Configuration Example

```nix
languages.doc = {
  enable = true;
  outputPath = "gen/doc";
  format = "html";  # html, markdown, json, or docbook
  outputFile = "index.html";
  options = [];  # or custom options like ["html,index.html"]
};
```

#### Generated Files

For a proto file collection:

- `index.html` - Complete API documentation (if format = "html")
- `index.md` - Markdown documentation (if format = "markdown")
- `index.json` - Structured JSON documentation (if format = "json")
- `index.xml` - DocBook XML documentation (if format = "docbook")

### SVG Diagrams

**Location**: `src/languages/svg/`

SVG support provides visual diagrams of Protocol Buffer schemas using protoc-gen-d2.

#### Available Plugins

- **`default.nix`** - SVG diagram generation (`protoc-gen-d2`)

#### Configuration Example

```nix
languages.svg = {
  enable = true;
  outputPath = "gen/svg";
  options = [];  # protoc-gen-d2 specific options
};
```

#### Generated Files

For a proto file `user/v1/user.proto`:

- SVG diagrams showing:
  - Message structures and relationships
  - Service definitions and RPC methods
  - Enum types and their values
  - Field types and connections between messages

#### Features

- Visual representation of complex proto schemas
- Automatic relationship detection
- Service method visualization
- Clear hierarchy and structure display

### Swift

**Location**: `src/languages/swift/`

Swift support provides Protocol Buffer message generation for iOS, macOS, and server applications.

#### Available Plugins

- **`default.nix`** - Protocol Buffer message generation (`protoc-gen-swift`)

#### Configuration Example

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

#### Generated Files

For a proto file `user/v1/user.proto`:

- `user_v1_user.pb.swift` - Protocol Buffer message types with Codable support

#### Integration Example

```swift
import Foundation
import SwiftProtobuf

// Import generated code
import MyAppProto

// Create a user message
var user = User_V1_User()
user.id = "user123"
user.name = "John Doe"
user.email = "john@example.com"
user.createdAt = Int64(Date().timeIntervalSince1970)

// Serialize to binary
let binaryData = try user.serializedData()
print("Binary size: \(binaryData.count) bytes")

// Serialize to JSON
let jsonData = try user.jsonUTF8Data()
let jsonString = String(data: jsonData, encoding: .utf8)!
print("JSON: \(jsonString)")

// Deserialize from binary
let decodedUser = try User_V1_User(serializedData: binaryData)
print("Decoded user: \(decodedUser.name)")

// Deserialize from JSON
let jsonUser = try User_V1_User(jsonUTF8Data: jsonData)
print("JSON user: \(jsonUser.name)")
```

## Module Structure

Each language module follows this structure:

```
languages/
├── c/
│   ├── default.nix       # Main entry point for C code generation
│   ├── nanopb.nix        # Nanopb plugin for embedded C
│   └── protobuf-c.nix    # Protobuf-c standard implementation
├── cpp/
│   ├── default.nix       # Main entry point for C++ code generation
│   ├── grpc.nix          # gRPC plugin for C++
│   ├── cmake.nix         # CMake integration and build support
│   └── plugins.nix       # Plugin definitions and registry
├── dart/
│   ├── default.nix       # Main entry point for Dart code generation
│   └── grpc.nix          # gRPC plugin for Dart
├── doc/
│   └── default.nix       # Documentation generation (HTML, Markdown, etc.)
├── go/
│   ├── default.nix       # Main entry point for Go code generation
│   ├── grpc.nix          # gRPC plugin for Go
│   ├── connect.nix       # Connect plugin for Go
│   ├── gateway.nix       # gRPC-Gateway plugin for Go
│   ├── validate.nix      # Legacy validate plugin for Go
│   ├── protovalidate.nix # Modern CEL-based validation
│   ├── vtprotobuf.nix    # High-performance serialization
│   ├── json.nix          # JSON integration plugin
│   ├── federation.nix    # gRPC Federation for BFF
│   ├── plugin-registry.nix # Buf registry plugin mappings
│   └── plugins.nix       # Dynamic plugin configuration
├── js/
│   ├── default.nix       # Main entry point for JavaScript code generation
│   ├── grpc-web.nix      # gRPC-Web plugin for JS
│   └── twirp.nix         # Twirp plugin for JS
├── php/
│   ├── default.nix       # Main entry point for PHP code generation
│   └── twirp.nix         # Twirp plugin for PHP
├── python/
│   ├── default.nix       # Main entry point for Python code generation
│   ├── betterproto.nix   # Betterproto modern dataclasses
│   ├── grpc.nix          # gRPC plugin for Python
│   ├── mypy.nix          # Mypy type stubs
│   └── pyi.nix           # Python type stub generation
├── svg/
│   └── default.nix       # SVG diagram generation with protoc-gen-d2
├── swift/
│   └── default.nix       # Main entry point for Swift code generation
└── module-template.nix   # Template for new language modules
```

## Language Module Interface

Each language module must implement the following interface:

```nix
{
  # Runtime inputs required for code generation
  runtimeInputs = [
    # packages required for this language
  ];

  # Protoc plugin configuration
  protocPlugins = [
    # Parameters to pass to protoc for this language
  ];

  # Command options for protoc
  commandOptions = [
    # CLI options to pass to the protoc command
  ];

  # Initialization hooks for this language
  initHooks = ''
    # Shell script code to run during initialization
  '';

  # Code generation hooks for this language
  generateHooks = ''
    # Shell script code to run during code generation
  '';
}
```

## Adding a New Language Module

To add support for a new language:

### 1. Create the Module Directory

```bash
mkdir src/languages/newlang
```

### 2. Implement the Base Module

Create `src/languages/newlang/default.nix`:

```nix
{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.languages.newlang;
in {
  runtimeInputs = with pkgs; [
    protobuf
    # Add language-specific protoc plugins
  ];

  protocPlugins = optionals cfg.enable [
    "--newlang_out=${cfg.outputPath}"
  ] ++ optionals (cfg.options != []) [
    "--newlang_opt=${concatStringsSep "," cfg.options}"
  ];

  commandOptions = [];

  initHooks = optionalString cfg.enable ''
    echo "Initializing NewLang code generation..."
    mkdir -p "${cfg.outputPath}"
  '';

  generateHooks = optionalString cfg.enable ''
    echo "Generated NewLang code in ${cfg.outputPath}"
  '';
}
```

### 3. Add Configuration Options

Add to `src/lib/bufrnix-options.nix`:

```nix
# NewLang language options
newlang = {
  enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable NewLang code generation";
  };

  outputPath = mkOption {
    type = types.str;
    default = "gen/newlang";
    description = "Output directory for generated NewLang code";
  };

  options = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Options to pass to protoc-gen-newlang";
  };

  # Add plugin-specific options here
};
```

### 4. Create an Example

Create a working example in `examples/newlang-example/` demonstrating:

- Basic project setup with flake.nix
- Proto file definitions
- Generated code usage
- README with instructions

### 5. Update Documentation

- Add the language to this README
- Update the main project README
- Add configuration examples
- Document any special requirements or limitations

## Testing Language Modules

Test your language module with the example projects:

```bash
# Test with a specific example
cd examples/simple-flake
nix build

# Test multi-language generation
cd examples/
# Add your language to an existing example's configuration
nix build
```

## Best Practices

### Configuration Design

1. **Sensible Defaults**: Provide working defaults for all options
2. **Clear Naming**: Use descriptive option names that match protoc conventions
3. **Documentation**: Add clear descriptions for all options
4. **Validation**: Use appropriate Nix types for validation

### Code Generation

1. **Output Structure**: Follow language conventions for package/namespace structure
2. **Error Handling**: Provide clear error messages for common issues
3. **Deterministic Output**: Ensure builds are reproducible
4. **Clean Output**: Only generate files that are actually needed

### Testing

1. **Complete Examples**: Provide working examples that demonstrate all features
2. **Error Cases**: Test with invalid configurations and proto files
3. **Integration**: Test generated code works with language-specific tools
4. **Cross-Platform**: Ensure modules work on different systems

## Plugin Dependencies

### Common Protoc Plugins

Available in nixpkgs:

- `protoc-gen-go` - Go message generation
- `protoc-gen-go-grpc` - Go gRPC generation
- `protoc-gen-grpc-gateway` - gRPC to HTTP/JSON gateway
- `protoc-gen-validate` - Legacy message validation
- `protoc-gen-connect-go` - Connect protocol for Go
- `protoc-gen-dart` - Dart message and gRPC generation
- `protoc-gen-js` - JavaScript message generation
- `protoc-gen-grpc-web` - gRPC-Web for browsers
- `protoc-gen-php` - PHP message generation
- `protoc-gen-swift` - Swift message generation

Plugins requiring custom packaging (not yet in nixpkgs):

- `protovalidate-go` - Modern CEL-based validation runtime
- `protoc-gen-go-vtproto` - High-performance Go serialization
- `protoc-gen-go-json` - JSON integration for Go
- `protoc-gen-grpc-federation` - gRPC Federation for BFF

### Custom Plugins

For plugins not in nixpkgs, add them to the module:

```nix
let
  customPlugin = pkgs.buildGoModule {
    pname = "protoc-gen-custom";
    version = "1.0.0";
    src = fetchFromGitHub { /* ... */ };
    vendorHash = "sha256-...";
  };
in {
  runtimeInputs = [ customPlugin ];
  # ...
}
```

## Module Configuration Patterns

### Simple Language Module

For languages with basic protoc support:

```nix
languages.simple = {
  enable = true;
  outputPath = "gen/simple";
  options = ["some_option=value"];
};
```

### Complex Multi-Plugin Module

For languages with multiple plugins:

```nix
languages.complex = {
  enable = true;
  outputPath = "gen/complex";

  grpc.enable = true;
  validate.enable = true;

  customPlugin = {
    enable = true;
    options = ["custom_opt=value"];
  };
};
```

### Conditional Plugin Loading

For optional plugin support:

```nix
let
  plugins = []
    ++ optional cfg.enable basicPlugin
    ++ optional cfg.grpc.enable grpcPlugin
    ++ optional cfg.advanced.enable advancedPlugin;
in {
  runtimeInputs = plugins;
  # ...
}
```

## Troubleshooting

### Common Issues

**Plugin Not Found**

```
protoc: --newlang_out: Plugin not found or is not executable
```

**Solution**: Ensure the plugin is in `runtimeInputs` and executable.

**Output Directory Issues**

```
protoc: newlang: directory does not exist
```

**Solution**: Create output directories in `initHooks`.

**Import Path Issues**

```
Import "path/to/proto" was not found
```

**Solution**: Verify `includeDirectories` configuration includes all necessary paths.

### Debug Mode

Enable debug mode for detailed information:

```nix
config = {
  debug = {
    enable = true;
    verbosity = 3;
  };
  languages.newlang.enable = true;
};
```

This will show:

- Protoc command line arguments
- Plugin execution details
- File generation progress
- Error messages with context

### Module Validation

Test your module systematically:

1. **Configuration Validation**: Test with invalid options
2. **File Generation**: Verify correct files are generated
3. **Output Quality**: Check generated code compiles/runs
4. **Error Handling**: Test error conditions and messages
5. **Documentation**: Ensure examples work as documented

For more help, see the [main troubleshooting guide](../../doc/src/content/docs/guides/troubleshooting.md) or open an issue on GitHub.
