#!/usr/bin/env bash
set -e

# Create test directories
mkdir -p proto gen/php

# Create a simple proto file
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

# List generated files
echo "Generated files:"
find gen/php -type f | sort

echo "Test completed successfully!"