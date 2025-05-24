# Bufrnix

Nix powered Protocol Buffers with declarative code generation and comprehensive developer tooling.

## Overview

Bufrnix provides a **declarative, reproducible way** to generate Protocol Buffer code for multiple languages through Nix flakes. It eliminates the complexity of managing protoc plugins, dependencies, and build environments by leveraging Nix's deterministic package management.

### Key Features

- 🚀 **Multi-language Support**: Go, Dart, JavaScript/TypeScript, PHP with more coming
- 🔧 **Rich Plugin Ecosystem**: gRPC, Connect, gRPC-Web, gRPC-Gateway, Twirp, and validation
- 📦 **Zero Setup**: All dependencies managed through Nix
- 🎯 **Declarative Configuration**: Type-safe configuration with clear error messages  
- 🔄 **Reproducible Builds**: Same output across all machines and CI/CD
- ⚡ **Developer Experience**: Comprehensive tooling, formatting, linting, and language servers included

## Quick Start

### 1. Basic Usage

Create a `flake.nix` in your project root:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufr.nix";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, bufrnix, ... }: 
  let
    system = "x86_64-linux";  # or your system
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.default = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib;
      inherit pkgs;
      config = {
        root = ./.;
        protoc = {
          files = ["./proto/user/v1/user.proto"];
        };
        languages.go = {
          enable = true;
          outputPath = "gen/go";
          grpc.enable = true;
        };
      };
    };
  };
}
```

### 2. Create Your Proto Files

```protobuf
// proto/user/v1/user.proto
syntax = "proto3";

package user.v1;

option go_package = "example.com/user/v1;userv1";

service UserService {
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
  rpc GetUser(GetUserRequest) returns (GetUserResponse);
}

message CreateUserRequest {
  string name = 1;
  string email = 2;
}

message CreateUserResponse {
  User user = 1;
}

message GetUserRequest {
  string id = 1;
}

message GetUserResponse {
  User user = 1;
}

message User {
  string id = 1;
  string name = 2;
  string email = 3;
  int64 created_at = 4;
}
```

### 3. Generate Code

```bash
nix build
```

Generated code will appear in `gen/go/user/v1/`:
- `user.pb.go` - Protocol Buffer messages
- `user_grpc.pb.go` - gRPC service definitions

## Comprehensive Examples

### Multi-Language Project

Generate code for multiple languages simultaneously:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufr.nix";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, bufrnix, ... }: {
    packages.default = bufrnix.lib.mkBufrnixPackage {
      inherit (nixpkgs.legacyPackages.x86_64-linux) lib pkgs;
      config = {
        root = ./.;
        protoc = {
          sourceDirectories = ["./proto"];
          includeDirectories = ["./proto"];
          files = [
            "./proto/user/v1/user.proto"
            "./proto/product/v1/product.proto"
          ];
        };
        
        # Go with full gRPC ecosystem
        languages.go = {
          enable = true;
          outputPath = "gen/go";
          options = ["paths=source_relative"];
          grpc.enable = true;
          gateway.enable = true;      # HTTP/JSON transcoding
          validate.enable = true;     # Message validation
          connect.enable = true;      # Modern Connect protocol
        };
        
        # Dart for Flutter applications
        languages.dart = {
          enable = true;
          outputPath = "lib/proto";
          packageName = "my_app_proto";
          grpc.enable = true;
        };
        
        # JavaScript for web and Node.js
        languages.js = {
          enable = true;
          outputPath = "src/proto";
          packageName = "my-proto";
          es.enable = true;           # Modern ECMAScript modules
          connect.enable = true;      # Connect-ES for modern RPC
          grpcWeb.enable = true;      # Browser-compatible gRPC
          twirp.enable = true;        # Twirp RPC framework
        };
        
        # PHP with Twirp support
        languages.php = {
          enable = true;
          outputPath = "gen/php";
          namespace = "MyApp\\Proto";
          twirp.enable = true;
        };
      };
    };
  };
}
```

### Advanced Go Configuration

For Go projects requiring the full ecosystem:

```nix
languages.go = {
  enable = true;
  outputPath = "internal/proto";
  packagePrefix = "github.com/myorg/myproject";
  options = [
    "paths=source_relative"
    "require_unimplemented_servers=false"
  ];
  
  # Core gRPC support
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

### Modern JavaScript/TypeScript Setup

For modern web applications:

```nix
languages.js = {
  enable = true;
  outputPath = "src/generated";
  packageName = "@myorg/proto";
  
  # Modern ECMAScript modules
  es = {
    enable = true;
    options = [
      "target=ts"                    # Generate TypeScript
      "import_extension=.js"         # ES module extensions
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
};
```

## Language Support

### Go
- **Plugins**: `protoc-gen-go`, `protoc-gen-go-grpc`, `protoc-gen-grpc-gateway`, `protoc-gen-validate`, `protoc-gen-connect-go`
- **Features**: Full gRPC ecosystem, HTTP gateways, validation, modern Connect protocol
- **Output**: Standard Go packages with proper module support

### Dart  
- **Plugins**: `protoc-gen-dart`
- **Features**: Complete protobuf and gRPC support for Flutter and server applications
- **Output**: Dart classes with full type safety and gRPC clients/servers

### JavaScript/TypeScript
- **Plugins**: `protoc-gen-js`, `protoc-gen-es`, `protoc-gen-connect-es`, `protoc-gen-grpc-web`, `protoc-gen-twirp_js`
- **Features**: CommonJS, ES modules, Connect-ES, gRPC-Web, Twirp support
- **Output**: Modern JavaScript with TypeScript definitions

### PHP
- **Plugins**: `protoc-gen-php`, `protoc-gen-twirp_php`  
- **Features**: Standard protobuf messages and Twirp RPC framework
- **Output**: PSR-4 compatible PHP classes

## Working Examples

Explore complete working examples in the `examples/` directory:

### [Simple Go gRPC Example](examples/simple-flake/)
```bash
cd examples/simple-flake
nix develop
go run main.go
```
- Basic gRPC server and client
- User management service
- Error handling and validation

### [Comprehensive Dart Example](examples/dart-example/) 
```bash
cd examples/dart-example
nix develop
dart pub get
dart run lib/main.dart
dart test
```
- Complex protobuf messages with all field types
- Complete gRPC client implementation 
- Comprehensive test suite

### [Modern JavaScript Example](examples/js-example/)
```bash
cd examples/js-example
nix develop
npm install && npm run build && npm start
```
- Multiple JavaScript output formats
- Connect-ES and gRPC-Web clients
- TypeScript integration

### [PHP Twirp Example](examples/php-twirp/)
```bash
cd examples/php-twirp
nix develop
composer install
php -S localhost:8080 -t src/
```
- Twirp RPC server and client
- PSR-4 autoloading
- JSON-over-HTTP communication

## Development Environment

### Prerequisites

- [Nix](https://nixos.org/download.html) with [flakes enabled](https://nixos.wiki/wiki/Flakes)
- That's it! All other dependencies are managed by Nix

### Setup

```bash
# Clone the repository
git clone https://github.com/conneroisu/bufr.nix.git
cd bufr.nix

# Enter development environment  
nix develop

# Available commands:
dx        # Edit flake.nix
lint      # Run Nix linting (statix + deadnix)
nix fmt   # Format all files (Nix, Markdown, TypeScript, YAML)
```

### Documentation Development

```bash
cd doc
nix develop
bun install
bun run dev     # http://localhost:4321
bun run build   # Build static site
```

## Configuration Reference

### Root Configuration

```nix
config = {
  # Required: Root directory containing proto files
  root = "./proto";
  
  # Protoc configuration
  protoc = {
    sourceDirectories = ["./proto"];      # Where to find .proto files
    includeDirectories = ["./proto"];     # Include path for imports
    files = [                             # Optional: specific files to compile
      "./proto/user/v1/user.proto"      # If empty, compiles all .proto files
    ];
  };
  
  # Debug configuration
  debug = {
    enable = false;                       # Enable debug output
    verbosity = 1;                        # 1-3, higher = more verbose
    logFile = "";                         # Empty = stdout, or path to file
  };
  
  # Language configurations (see language-specific docs)
  languages = { ... };
};
```

### Language-Specific Options

Each language module supports:

- `enable`: Boolean to enable/disable the language
- `outputPath`: Where to place generated files (relative to root)
- `options`: Array of options passed to the base protoc plugin
- Plugin-specific configuration (e.g., `grpc.enable`, `connect.enable`)

See the [Language Modules Documentation](src/languages/README.md) for complete details.

## Advanced Usage

### Custom Proto Dependencies

```nix
protoc = {
  includeDirectories = [
    "./proto"
    "${pkgs.protobuf}/include"           # Include well-known types
    "${googleapis}/google/api"           # Google API protos
  ];
};
```

### CI/CD Integration

```yaml
# .github/workflows/protobuf.yml
name: Generate Protobuf Code
on: [push, pull_request]
jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v22
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes
      - run: nix build
      - run: git diff --exit-code  # Ensure generated code is up-to-date
```

### Multiple Output Configurations

Generate different outputs for different environments:

```nix
{
  packages = {
    # Production build with optimizations
    prod = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib;
      inherit pkgs;
      config = {
        languages.go = {
          enable = true;
          options = ["paths=source_relative" "Mgrpc/service_config/service_config.proto=google.golang.org/grpc/serviceconfig"];
        };
      };
    };
    
    # Development build with validation and debugging
    dev = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib;  
      inherit pkgs;
      config = {
        debug.enable = true;
        languages.go = {
          enable = true;
          validate.enable = true;
          gateway.enable = true;
        };
      };
    };
  };
}
```

## Contributing

1. **Fork and clone** the repository
2. **Make changes** to language modules or core functionality
3. **Test** with the example projects
4. **Update documentation** as needed
5. **Submit a pull request**

### Adding Language Support

1. Create a new module in `src/languages/`
2. Add configuration options to `src/lib/bufrnix-options.nix`
3. Create a working example in `examples/`
4. Update documentation

See the [Language Modules README](src/languages/README.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- [Protocol Buffers](https://developers.google.com/protocol-buffers) - Google's language-neutral data serialization
- [Nix](https://nixos.org/) - Reproducible package management and builds
- [Connect](https://connect.build/) - Modern, type-safe RPC framework
- [gRPC](https://grpc.io/) - High-performance RPC framework
- [Twirp](https://github.com/twitchtv/twirp) - Simple RPC framework for service-to-service communication

---

**Questions?** Check out the [documentation](doc/), browse the [examples](examples/), or open an issue!