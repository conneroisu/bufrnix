# PHP gRPC with RoadRunner Example

This example demonstrates Bufrnix's comprehensive PHP support including:

- gRPC client and server generation
- High-performance RoadRunner server
- Async PHP with ReactPHP, Swoole, and Fibers
- Framework integration capabilities

## Features Demonstrated

1. **Protocol Buffer Message Generation** - Standard PHP protobuf classes
2. **gRPC Client Generation** - Full-featured gRPC client stubs
3. **RoadRunner Server** - High-performance, persistent PHP workers
4. **Async Support** - ReactPHP, Swoole/OpenSwoole, and PHP 8.1+ Fibers
5. **Developer Experience** - Auto-generated composer.json, examples, and helpers

## Getting Started

### 1. Enter Development Shell

```bash
nix develop
```

This will:

- Set up PHP with gRPC and protobuf extensions
- Install RoadRunner
- Configure all development tools
- Create initial project structure

### 2. Define Your Protocol Buffers

Create `proto/example/v1/service.proto`:

```protobuf
syntax = "proto3";

package example.v1;

option php_namespace = "App\\Proto\\Example\\V1";
option php_metadata_namespace = "App\\Proto\\Metadata\\Example\\V1";

service GreeterService {
  rpc SayHello (HelloRequest) returns (HelloResponse);
  rpc SayHelloStream (HelloRequest) returns (stream HelloResponse);
  rpc SayHelloBidirectional (stream HelloRequest) returns (stream HelloResponse);
}

message HelloRequest {
  string name = 1;
  int32 count = 2;
}

message HelloResponse {
  string message = 1;
  int64 timestamp = 2;
}
```

### 3. Generate PHP Code

```bash
buf generate
```

This generates:

- Message classes in `gen/php/App/Proto/Example/V1/`
- gRPC service interfaces and clients
- RoadRunner-compatible server stubs
- Example implementations and templates

### 4. Install PHP Dependencies

```bash
composer install
```

The auto-generated `composer.json` includes all necessary dependencies.

### 5. Implement Your Service

Create `src/Services/GreeterService.php`:

```php
<?php

namespace App\Services;

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

        return $response;
    }

    public function SayHelloStream(
        ContextInterface $ctx,
        HelloRequest $request
    ): \Generator {
        for ($i = 0; $i < $request->getCount(); $i++) {
            $response = new HelloResponse();
            $response->setMessage("Hello #$i, " . $request->getName() . "!");
            $response->setTimestamp(time());

            yield $response;

            usleep(500000); // 500ms delay
        }
    }

    public function SayHelloBidirectional(
        ContextInterface $ctx,
        \Iterator $requests
    ): \Generator {
        foreach ($requests as $request) {
            $response = new HelloResponse();
            $response->setMessage("Echo: Hello, " . $request->getName() . "!");
            $response->setTimestamp(time());

            yield $response;
        }
    }
}
```

### 6. Update RoadRunner Worker

Edit the generated `worker.php`:

```php
<?php
declare(strict_types=1);

use Spiral\RoadRunner\GRPC\Server;
use Spiral\RoadRunner\Worker;
use App\Services\GreeterService;
use App\Proto\Example\V1\Services\GreeterServiceInterface;

require __DIR__ . '/vendor/autoload.php';

$server = new Server(null, [
    'debug' => false,
]);

// Register your service
$server->registerService(
    GreeterServiceInterface::class,
    new GreeterService()
);

$server->serve(Worker::create());
```

### 7. Start the Server

```bash
./roadrunner-dev.sh start
```

Or in debug mode:

```bash
./roadrunner-dev.sh debug
```

### 8. Test with Client

Create `test-client.php`:

```php
<?php

require __DIR__ . '/vendor/autoload.php';

use App\Proto\Example\V1\HelloRequest;
use App\Proto\Example\V1\Services\GreeterServiceClient;
use Grpc\ChannelCredentials;

$client = new GreeterServiceClient('localhost:9001', [
    'credentials' => ChannelCredentials::createInsecure(),
]);

// Simple unary call
$request = new HelloRequest();
$request->setName('Bufrnix');

[$response, $status] = $client->SayHello($request)->wait();

if ($status->code === \Grpc\STATUS_OK) {
    echo "Response: " . $response->getMessage() . "\n";
    echo "Timestamp: " . $response->getTimestamp() . "\n";
} else {
    echo "Error: " . $status->details . "\n";
}

// Streaming call
$request->setCount(5);
$call = $client->SayHelloStream($request);

foreach ($call->responses() as $response) {
    echo "Stream: " . $response->getMessage() . "\n";
}
```

Run the client:

```bash
php test-client.php
```

## Async Examples

### ReactPHP Client

```php
use App\Proto\Async\ReactPHPClient;
use App\Proto\Example\V1\HelloRequest;

$client = new ReactPHPClient('localhost:9001');

$request = new HelloRequest();
$request->setName('Async World');

$client->sendRequestAsync($request)->then(
    function ($response) {
        echo "Async response: " . $response->getMessage() . "\n";
    },
    function ($error) {
        echo "Error: " . $error->getMessage() . "\n";
    }
);

$client->run();
```

### Swoole Server

```php
use App\Proto\Async\SwooleGrpcServer;
use App\Services\GreeterService;

$server = new SwooleGrpcServer('0.0.0.0', 9502);
$server->registerService(
    GreeterServiceInterface::class,
    new GreeterService()
);
$server->start();
```

### PHP Fibers

```php
use App\Proto\Async\FiberProtobufHandler;

$handler = new FiberProtobufHandler();

// Process multiple messages concurrently
$messages = [
    'msg1' => $request1->serializeToString(),
    'msg2' => $request2->serializeToString(),
    'msg3' => $request3->serializeToString(),
];

$results = $handler->processConcurrent($messages);
```

## Performance Tuning

### RoadRunner Configuration

Edit `.rr.yaml` to tune performance:

```yaml
grpc:
  pool:
    num_workers: 8 # Increase for more concurrency
    max_jobs: 500 # Jobs before worker restart
    supervisor:
      max_worker_memory: 256 # MB per worker
```

### PHP Extensions

Install C extensions for better performance:

```bash
pecl install protobuf
pecl install grpc
```

## Framework Integration

### Laravel

Enable Laravel support in `flake.nix`:

```nix
frameworks.laravel = {
  enable = true;
  serviceProvider = true;
  artisanCommands = true;
};
```

Then use artisan commands:

```bash
php artisan protobuf:generate
php artisan grpc:serve
php artisan grpc:health
```

### Symfony

Enable Symfony support:

```nix
frameworks.symfony = {
  enable = true;
  bundle = true;
  messengerIntegration = true;
};
```

Use Symfony commands:

```bash
bin/console protobuf:generate
bin/console grpc:worker
```

## Troubleshooting

### Common Issues

1. **Extension not loaded**

   - Check `php -m | grep grpc`
   - Ensure extensions are enabled in php.ini

2. **RoadRunner workers crashing**

   - Check logs: `./roadrunner-dev.sh workers`
   - Increase memory limit in .rr.yaml

3. **Connection refused**
   - Verify server is running: `ps aux | grep roadrunner`
   - Check port availability: `lsof -i :9001`

### Debug Mode

Enable debug logging:

```bash
# In .rr.yaml
logs:
  level: debug

# Start with debug flag
./roadrunner-dev.sh debug
```

## Next Steps

- Add authentication with gRPC interceptors
- Implement health checks
- Add Prometheus metrics
- Deploy with Docker/Kubernetes
- Integrate with API gateway
