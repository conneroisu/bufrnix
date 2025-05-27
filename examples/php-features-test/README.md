# PHP Features Test Suite

This directory contains comprehensive tests for all PHP language features in Bufrnix.

## Features Tested

### 1. Basic Protobuf Generation (`nix develop .#basic`)

Tests basic PHP protobuf message generation with:

- Custom namespace: `BasicTest\Messages`
- Custom metadata namespace: `BasicTest\Meta`
- Class prefix: `BT`
- Composer integration

**Generated files:**

- `gen/php/basic/BasicTest/Messages/BTTestMessage.php`
- `gen/php/basic/BasicTest/Meta/Test/V1.php`

### 2. gRPC Support (`nix develop .#grpc`)

Tests gRPC client and server stub generation:

- Service namespace: `Svc`
- Both client and server interfaces
- All RPC patterns (unary, streaming, bidirectional)

**Generated files:**

- `*ServiceClient.php` - gRPC client classes
- `*ServiceInterface.php` - Service interfaces for implementation

### 3. RoadRunner Server (`nix develop .#roadrunner`)

Tests high-performance RoadRunner server integration:

- Worker configuration (2 workers, 50 max jobs, 64MB memory)
- Development scripts
- Service registry helpers

**Generated files:**

- `.rr.yaml` - RoadRunner configuration
- `worker.php` - Worker entry point
- `roadrunner-dev.sh` - Development helper script
- Performance monitoring utilities

### 4. Laravel Integration (`nix develop .#laravel`)

Tests Laravel framework integration:

- Service provider generation
- Artisan commands
- Configuration files

**Generated files:**

- `app/Providers/ProtobufServiceProvider.php`
- `app/Console/Commands/ProtobufGenerate.php`
- `app/Console/Commands/GrpcServe.php`
- `app/Console/Commands/GrpcHealthCheck.php`
- `config/grpc.php`

### 5. Symfony Integration (`nix develop .#symfony`)

Tests Symfony framework integration:

- Bundle creation
- Console commands
- Messenger integration

**Generated files:**

- `src/Protobuf/ProtobufBundle.php`
- `src/Command/ProtobufGenerateCommand.php`
- `src/MessageHandler/ProtobufMessageHandler.php`
- `config/packages/protobuf.yaml`

### 6. Async PHP Support (`nix develop .#async`)

Tests all async PHP implementations:

- ReactPHP (event-driven, promises)
- Swoole/OpenSwoole (coroutines)
- PHP 8.1+ Fibers

**Generated files:**

- `gen/php/async/Async/ReactPHPClient.php`
- `gen/php/async/Async/ReactPHPServer.php`
- `gen/php/async/Async/SwooleGrpcServer.php`
- `gen/php/async/Async/SwooleGrpcClient.php`
- `gen/php/async/Async/FiberProtobufHandler.php`

### 7. Client-Only Mode (`nix develop .#clientOnly`)

Tests client-only gRPC generation:

- Only client stubs generated
- No server interfaces
- Useful for API consumers

### 8. Full Features (`nix develop .#full`)

Tests all features combined:

- All generation options enabled
- Complete composer.json with all dependencies
- TLS support enabled
- All async patterns
- Laravel integration
- Maximum configuration

## Running Tests

### Quick Test All

```bash
./test-all.sh
```

This script will:

1. Test each configuration separately
2. Verify files are generated correctly
3. Check namespaces and dependencies
4. Report success/failure for each test

### Test Individual Features

```bash
# Test basic protobuf generation
nix develop .#basic
buf generate
ls -la gen/php/basic/

# Test gRPC support
nix develop .#grpc
buf generate
find gen/php/grpc -name "*Service*.php"

# Test RoadRunner
nix develop .#roadrunner
buf generate
cat .rr.yaml
./roadrunner-dev.sh start

# Test Laravel
nix develop .#laravel
buf generate
tree app/
cat config/grpc.php

# Test async features
nix develop .#async
buf generate
php test-async-features.php
```

## Configuration Examples

### Custom Namespace Configuration

```nix
namespace = "MyCompany\\Proto";
metadataNamespace = "MyCompany\\Metadata";
classPrefix = "MC";
```

Generates:

- Classes like `MyCompany\Proto\MCTestMessage`
- Metadata in `MyCompany\Metadata\*`

### gRPC Options

```nix
grpc = {
  enable = true;
  serviceNamespace = "Services";  # Appended to base namespace
  clientOnly = false;            # Generate both client and server
};
```

### RoadRunner Configuration

```nix
roadrunner = {
  enable = true;
  workers = 4;        # Number of PHP workers
  maxJobs = 100;      # Jobs before worker restart
  maxMemory = 128;    # MB per worker
  tlsEnabled = true;  # Enable TLS support
};
```

### Async Configuration

```nix
async = {
  reactphp = {
    enable = true;
    version = "^1.3";  # ReactPHP version constraint
  };

  swoole = {
    enable = true;
    coroutines = true;  # Enable coroutine support
  };

  fibers = {
    enable = true;      # Requires PHP 8.1+
  };
};
```

## Generated Code Structure

```
gen/php/{config}/
├── {Namespace}/
│   ├── TestMessage.php           # Message classes
│   ├── NestedMessage.php
│   ├── TestEnum.php             # Enum classes
│   ├── ComplexMessage.php
│   └── Services/                # If gRPC enabled
│       ├── TestServiceClient.php
│       └── TestServiceInterface.php
├── {MetadataNamespace}/         # Protobuf metadata
│   └── Test/
│       └── V1.php
└── Async/                       # If async enabled
    ├── ReactPHPClient.php
    ├── ReactPHPServer.php
    ├── SwooleGrpcServer.php
    └── FiberProtobufHandler.php
```

## Composer Dependencies

Based on enabled features, the generated `composer.json` includes:

```json
{
  "require": {
    "php": ">=7.4",
    "google/protobuf": "^3.21", // Always included
    "grpc/grpc": "^1.50", // If gRPC enabled
    "spiral/roadrunner-grpc": "^3.0", // If RoadRunner enabled
    "spiral/roadrunner-worker": "^3.0", // If RoadRunner enabled
    "react/event-loop": "^1.0", // If ReactPHP enabled
    "react/promise": "^1.0", // If ReactPHP enabled
    "openswoole/core": "^22.0" // If Swoole enabled
  }
}
```

## Troubleshooting

### Common Issues

1. **"Code generation failed"**

   - Ensure you have `buf` available in the shell
   - Check that proto files are valid
   - Verify the flake configuration

2. **"Output directory not found"**

   - Make sure `buf generate` completed successfully
   - Check the `outputPath` configuration matches expectations

3. **"No namespace found"**

   - Verify namespace configuration in flake.nix
   - Check that PHP files were actually generated

4. **RoadRunner issues**
   - Ensure RoadRunner binary is available
   - Check `.rr.yaml` configuration
   - Verify worker.php was generated

## Next Steps

1. Use these examples as templates for your own projects
2. Customize the configuration for your needs
3. Integrate with your PHP framework of choice
4. Benchmark async implementations for your use case
