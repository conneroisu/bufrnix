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

## Learn More

- [Twirp GitHub Repository](https://github.com/twitchtv/twirp)
- [PHP Twirp Implementation](https://github.com/twirphp/twirp)
- [Protocol Buffers](https://developers.google.com/protocol-buffers)
- [Nix & NixOS](https://nixos.org/)
