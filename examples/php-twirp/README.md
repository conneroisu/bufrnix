# Bufrnix PHP Twirp Example

This example demonstrates how to use bufrnix to generate PHP code with the Twirp RPC framework. It showcases the PHP language module in bufrnix with the protoc-gen-twirp_php plugin, providing a complete example of a client-server RPC setup.

## What is Twirp?

[Twirp](https://github.com/twitchtv/twirp) is a simple RPC framework built on Protocol Buffers. The PHP implementation ([protoc-gen-twirp_php](https://github.com/twirphp/twirp)) provides a reliable way to create PHP services with a clean client/server architecture.

## Setup

1. Make sure you have [Nix installed](https://nixos.org/download.html) with flakes enabled
2. Clone this repository
3. Enter the example directory:

```bash
cd examples/php-twirp
```

4. Enter the Nix development shell:

```bash
nix develop
```

5. Set up the project:

```bash
setup-twirp-php
```

This will:
- Generate PHP code from the Protocol Buffer definitions
- Install PHP dependencies using Composer

## Running the Example

1. In one terminal, start the server:

```bash
run-server
```

Or directly:

```bash
php server.php
```

2. In another terminal, run the client:

```bash
run-client
```

Or directly:

```bash
php client.php
```

You should see the output: `Hello, World!`

## Project Structure

- `proto/example/v1/service.proto`: The Protocol Buffer definition of our service
- `server.php`: A simple implementation of the Twirp service
- `client.php`: A client that connects to the service
- `composer.json`: PHP dependencies
- `flake.nix`: Nix flake for the development environment

## Understanding the Code

### Service Definition (Proto)

```protobuf
syntax = "proto3";

package example.v1;

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
```

### Server Implementation

The server implements the interface defined by the Protocol Buffer:

```php
class HelloServiceImpl implements HelloServiceInterface {
    public function Hello(HelloRequest $request): HelloResponse {
        $response = new HelloResponse();
        $response->setGreeting("Hello, " . $request->getName() . "!");
        return $response;
    }
}
```

### Client Usage

The client uses the generated Twirp client to make RPC calls:

```php
$client = new HelloServiceClient('http://localhost:8080');
$request = new HelloRequest();
$request->setName("World");
$response = $client->Hello($request);
echo $response->getGreeting() . "\n";
```

## Bufrnix and Nix Development Environment

The Nix flake in this example demonstrates how to use bufrnix for PHP code generation:

```nix
# Create a bufrnix package for this project
bufrnixPackage = bufrnix.lib.mkBufrnixPackage {
  inherit (nixpkgs.legacyPackages.${system}) lib;
  inherit pkgs;
  config = {
    root = ./.;
    debug.enable = true;
    protoc = {
      sourceDirectories = ["./proto"];
      includeDirectories = ["./proto"];
    };
    languages.php = {
      enable = true;
      outputPath = "gen/php";
      namespace = "Example\\Twirp";
      twirp = {
        enable = true;
      };
    };
  };
};
```

The development environment includes:

- Bufrnix with PHP and Twirp support
- PHP 8.3 with all required extensions
- Composer for PHP dependency management
- Helper scripts for setting up and running the example

## Manual Setup (Without Nix)

If you don't want to use Nix, you can set up the project manually:

1. Install PHP (>= 7.4) with required extensions
2. Install Composer
3. Install Protocol Buffers (protoc)
4. Install protoc-gen-twirp_php
5. Generate code:

```bash
protoc --proto_path=proto \
       --php_out=gen/php \
       --twirp_php_out=gen/php \
       proto/example/v1/service.proto
```

6. Install dependencies:

```bash
composer install
```

7. Run the server and client as described above

## Learn More

- [Twirp GitHub Repository](https://github.com/twitchtv/twirp)
- [PHP Twirp Implementation](https://github.com/twirphp/twirp)
- [Protocol Buffers](https://developers.google.com/protocol-buffers)
- [Nix & NixOS](https://nixos.org/)