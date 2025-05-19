# Using protoc-gen-twirp_php with nix-shell

This guide demonstrates how to use the protoc-gen-twirp_php plugin with a nix-shell for quick testing and development.

## Quick Start with nix-shell

You can quickly try out the PHP Twirp generator using a nix-shell without setting up a full project:

```bash
# Enter a nix-shell with all required dependencies
nix-shell -p "php83.withExtensions ({ all, enabled }: with all; enabled ++ [ curl mbstring tokenizer xml ctype fileinfo json pdo dom ])" php83.packages.composer protobuf protoc-gen-twirp_php

# Inside the shell, you can generate code for your proto files
mkdir -p proto gen/php
cat > proto/example.proto << EOF
syntax = "proto3";

package example;

// Simple greeting service example
service HelloService {
  // Say hello
  rpc Hello(HelloRequest) returns (HelloResponse);
}

// Request message containing the person's name
message HelloRequest {
  string name = 1;
}

// Response message containing the greeting
message HelloResponse {
  string greeting = 1;
}
EOF

# Generate PHP code using protoc with Twirp PHP plugin
protoc --proto_path=proto \
       --php_out=gen/php \
       --twirp_php_out=gen/php \
       proto/example.proto

# Set up composer.json
cat > composer.json << EOF
{
  "name": "example/twirp-hello",
  "description": "Example PHP service using Protocol Buffers and Twirp",
  "type": "project",
  "license": "MIT",
  "autoload": {
    "psr-4": {
      "Example\\\\": "gen/php/"
    }
  },
  "require": {
    "php": ">=7.4",
    "twirp/twirp": "^0.8.0",
    "google/protobuf": "^3.19"
  }
}
EOF

# Install dependencies
composer install

# Create a server implementation
cat > server.php << EOF
<?php
require_once 'vendor/autoload.php';

use Example\HelloRequest;
use Example\HelloResponse;
use Example\HelloServiceInterface;

class HelloServiceImpl implements HelloServiceInterface {
    public function Hello(HelloRequest \$request): HelloResponse {
        \$response = new HelloResponse();
        \$response->setGreeting("Hello, " . \$request->getName() . "!");
        return \$response;
    }
}

// Create and run the server
\$addr = '127.0.0.1:8080';
\$server = new \Twirp\Server();
\$server->registerService(\Example\HelloServiceClient::SERVICE_NAME, new HelloServiceImpl());

echo "Starting Twirp server on \$addr\n";
\$server->serve(\$addr);
EOF

# Create a client implementation
cat > client.php << EOF
<?php
require_once 'vendor/autoload.php';

use Example\HelloRequest;
use Example\HelloServiceClient;

\$client = new HelloServiceClient('http://localhost:8080');

\$request = new HelloRequest();
\$request->setName("World");

try {
    \$response = \$client->Hello(\$request);
    echo \$response->getGreeting() . "\n";
} catch (Exception \$e) {
    echo "Error: " . \$e->getMessage() . "\n";
}
EOF

# Run the server in the background
php server.php &
SERVER_PID=$!

# Wait for the server to start
sleep 1

# Run the client
php client.php

# Stop the server
kill $SERVER_PID
```

## Explanation

This example demonstrates:

1. Creating a nix-shell with PHP 8.3, all required extensions, Composer, and the protoc-gen-twirp_php plugin
2. Defining a simple Protocol Buffer service
3. Generating PHP code using protoc with the Twirp PHP plugin
4. Setting up a Composer project with dependencies
5. Implementing a simple Twirp service
6. Creating a client to communicate with the service

## Production Use

For production use, consider using the main example with a proper Nix flake, which provides a more reproducible and stable development environment. See the main README.md for details.

Benefits of using the flake-based approach:
- Pinned dependencies for reproducibility
- Structured development environment
- Helper scripts for common tasks
- Better integration with the Nix ecosystem