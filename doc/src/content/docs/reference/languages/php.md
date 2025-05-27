---
title: PHP Language Support
description: Comprehensive guide to PHP Protocol Buffers and gRPC support in Bufrnix
---

Bufrnix provides comprehensive PHP support for Protocol Buffers and gRPC development, including message generation, gRPC clients and servers, high-performance RoadRunner integration, framework support, and modern async patterns.

## Features

- **Protocol Buffer Messages** - Generate PHP classes for all your protobuf messages
- **gRPC Support** - Full client and server code generation
- **RoadRunner Integration** - High-performance application server with persistent workers
- **Framework Integration** - Built-in support for Laravel and Symfony
- **Async PHP** - ReactPHP, Swoole/OpenSwoole, and PHP 8.1+ Fibers support
- **Developer Experience** - Auto-generated composer.json, examples, and helper scripts

## Quick Start

### Basic Configuration

```nix
# flake.nix
{
  languages.php = {
    enable = true;
    namespace = "App\\Proto";
  };
}
```

### With gRPC Support

```nix
{
  languages.php = {
    enable = true;
    namespace = "App\\Proto";
    
    grpc = {
      enable = true;
      serviceNamespace = "Services";
    };
  };
}
```

### Full-Featured Configuration

```nix
{
  languages.php = {
    enable = true;
    
    # Namespace configuration
    namespace = "App\\Proto";
    metadataNamespace = "Metadata";
    classPrefix = ""; # Optional prefix for all classes
    
    # Output directory
    outputPath = "gen/php";
    
    # Composer integration
    composer = {
      enable = true;
      autoInstall = false; # Auto-run composer install
    };
    
    # gRPC client generation
    grpc = {
      enable = true;
      serviceNamespace = "Services";
      clientOnly = false; # Generate both client and server
    };
    
    # RoadRunner server
    roadrunner = {
      enable = true;
      workers = 4;
      maxJobs = 100;
      maxMemory = 128;
      tlsEnabled = false;
    };
    
    # Framework support
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
        enable = false;
      };
    };
  };
}
```

## Configuration Options

### Core Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable PHP code generation |
| `package` | package | php with extensions | PHP package to use |
| `outputPath` | string | "gen/php" | Output directory for generated code |
| `namespace` | string | "Generated" | Base PHP namespace |
| `metadataNamespace` | string | "GPBMetadata" | Metadata namespace |
| `classPrefix` | string | "" | Prefix for generated classes |

### Composer Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `composer.enable` | bool | true | Enable Composer integration |
| `composer.autoInstall` | bool | false | Auto-install dependencies |

### gRPC Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `grpc.enable` | bool | false | Enable gRPC generation |
| `grpc.clientOnly` | bool | false | Generate only client code |
| `grpc.serviceNamespace` | string | "Services" | Service namespace suffix |

### RoadRunner Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `roadrunner.enable` | bool | false | Enable RoadRunner server |
| `roadrunner.workers` | int | 4 | Number of worker processes |
| `roadrunner.maxJobs` | int | 64 | Jobs before worker restart |
| `roadrunner.maxMemory` | int | 128 | Memory limit per worker (MB) |
| `roadrunner.tlsEnabled` | bool | false | Enable TLS support |

## Generated Files

When you run `buf generate`, Bufrnix creates:

```
gen/php/
├── App/
│   └── Proto/
│       ├── Example/
│       │   └── V1/
│       │       ├── HelloRequest.php      # Message class
│       │       ├── HelloResponse.php     # Message class
│       │       └── Services/
│       │           ├── GreeterServiceClient.php      # gRPC client
│       │           └── GreeterServiceInterface.php   # Service interface
│       ├── Metadata/                     # Protobuf metadata
│       ├── Async/                        # Async examples (if enabled)
│       ├── RoadRunner/                   # RoadRunner helpers
│       └── autoload.php                  # Autoloader helper
├── ExampleClient.php.template            # Client example
├── ExampleService.php.template           # Server implementation template
├── ServiceRegistry.php                   # RoadRunner service registry
└── PerformanceMonitor.php              # Performance monitoring helper

# Root directory files
.rr.yaml                                  # RoadRunner configuration
worker.php                                # RoadRunner worker script
composer.json                             # PHP dependencies
roadrunner-dev.sh                        # Development helper script
```

## Usage Examples

### Basic Message Usage

```php
use App\Proto\Example\V1\HelloRequest;
use App\Proto\Example\V1\HelloResponse;

// Create a request
$request = new HelloRequest();
$request->setName('World');
$request->setCount(5);

// Serialize to string
$data = $request->serializeToString();

// Deserialize from string
$decoded = new HelloRequest();
$decoded->mergeFromString($data);

echo $decoded->getName(); // "World"
```

### gRPC Client

```php
use App\Proto\Example\V1\Services\GreeterServiceClient;
use Grpc\ChannelCredentials;

// Create client
$client = new GreeterServiceClient('localhost:9001', [
    'credentials' => ChannelCredentials::createInsecure(),
]);

// Make unary call
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

### RoadRunner Server

```php
// worker.php
use Spiral\RoadRunner\GRPC\Server;
use Spiral\RoadRunner\Worker;

$server = new Server();
$server->registerService(
    GreeterServiceInterface::class,
    new GreeterService()
);
$server->serve(Worker::create());
```

Start the server:

```bash
./roadrunner-dev.sh start
```

### Framework Integration

#### Laravel

```php
// In a controller or service
public function __construct(
    private GreeterServiceClient $greeterClient
) {}

public function greet(Request $request)
{
    $grpcRequest = new HelloRequest();
    $grpcRequest->setName($request->input('name'));
    
    [$response, $status] = $this->greeterClient
        ->SayHello($grpcRequest)
        ->wait();
    
    return response()->json([
        'message' => $response->getMessage(),
    ]);
}
```

#### Symfony

```php
// In a controller
#[Route('/greet/{name}', name: 'greet')]
public function greet(
    string $name,
    GreeterServiceClient $client
): JsonResponse {
    $request = new HelloRequest();
    $request->setName($name);
    
    [$response, $status] = $client->SayHello($request)->wait();
    
    return $this->json([
        'message' => $response->getMessage(),
    ]);
}
```

### Async Examples

#### ReactPHP

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

#### Swoole

```php
use App\Proto\Async\SwooleGrpcServer;

$server = new SwooleGrpcServer('0.0.0.0', 9501);
$server->registerService(
    GreeterServiceInterface::class,
    new GreeterService()
);
$server->start();
```

#### PHP Fibers

```php
use App\Proto\Async\FiberProtobufHandler;

$handler = new FiberProtobufHandler();
$results = $handler->processConcurrent([
    'req1' => $request1->serializeToString(),
    'req2' => $request2->serializeToString(),
]);
```

## Performance Optimization

### PHP Extensions

Install C extensions for better performance:

```bash
pecl install protobuf
pecl install grpc
```

### RoadRunner Tuning

```yaml
# .rr.yaml
grpc:
  pool:
    num_workers: 8      # Increase for more concurrency
    max_jobs: 500       # More jobs before restart
    supervisor:
      max_worker_memory: 256  # Increase memory limit
```

### OPcache Configuration

```ini
; php.ini
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=256
opcache.max_accelerated_files=20000
```

## Troubleshooting

### Common Issues

**Extension not loaded**
```bash
php -m | grep -E '(grpc|protobuf)'
```

**RoadRunner workers crashing**
```bash
# Check worker status
./roadrunner-dev.sh workers

# View logs
./roadrunner-dev.sh debug
```

**Class not found errors**
```bash
# Regenerate autoloader
composer dump-autoload

# Check namespace configuration
grep namespace .rr.yaml
```

### Debug Mode

Enable detailed logging:

```yaml
# .rr.yaml
logs:
  level: debug
  output: stdout
```

## Migration from Twirp

If you're migrating from the deprecated Twirp support:

1. Update your flake.nix to enable gRPC instead of Twirp
2. Regenerate your code with `buf generate`
3. Update service implementations to use RoadRunner interfaces
4. Replace Twirp client calls with gRPC clients

## Best Practices

1. **Use RoadRunner** for production deployments
2. **Enable extensions** for better performance
3. **Configure workers** based on your workload
4. **Implement health checks** for monitoring
5. **Use streaming** for large data transfers
6. **Add metrics** for observability

## Related Documentation

- [Getting Started Guide](/guides/getting-started)
- [Example: PHP gRPC with RoadRunner](/guides/examples#php-grpc-roadrunner)
- [Go Language Support](/reference/languages/go)
- [Python Language Support](/reference/languages/python)