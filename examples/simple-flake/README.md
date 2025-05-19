# Simple gRPC Example with Bufrnix

This is a simple gRPC demonstration that shows how to use the proto-generated code with bufrnix in a project.

## Overview

This example demonstrates:
- A simple gRPC server implementing a UserService
- A gRPC client that connects to the server
- Proto definitions for User management
- Use of the generated Go code from protobuf

## Usage

Generate the code from the proto files:
```sh
nix run .\#packages.x86_64-linux.bufrnix generate
```

## Running the Demo

First, ensure the dependencies are installed:
```bash
go mod tidy
```

### Run both server and client together (default):
```bash
go run main.go
```

### Run only the server:
```bash
go run main.go -mode=server
```

### Run only the client:
```bash
go run main.go -mode=client
```

### Customize the port:
```bash
go run main.go -mode=server -port=:50052
go run main.go -mode=client -addr=localhost:50052
```

## The UserService

The service provides two RPCs:
1. `CreateUser` - Creates a new user with validation
2. `GetUser` - Retrieves a user by ID

The demo showcases:
- Creating a new user with complete information
- Retrieving the created user
- Error handling for non-existent users
- Thread-safe in-memory storage
- Use of protobuf message types including enums, repeated fields, and nested messages

## Proto Definition

The proto file defines:
- `User` message with fields like id, name, email, roles, and addresses
- `UserStatus` enum (ACTIVE, INACTIVE, SUSPENDED)
- Nested `Address` message within User
- Request/Response messages for the RPCs