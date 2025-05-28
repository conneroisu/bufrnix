# JavaScript gRPC-Web Example

This example demonstrates how to use bufrnix to generate JavaScript/TypeScript code for gRPC-Web applications. It includes a complete setup with:

- TypeScript gRPC server using `@grpc/grpc-js`
- gRPC-Web client connecting through Envoy proxy
- Two example services: UserService and ChatService
- Support for all RPC types: unary, server streaming, client streaming, and bidirectional streaming

## Prerequisites

- Nix with flakes enabled
- Node.js (provided by nix shell)
- Envoy proxy (provided by nix shell)

## Project Structure

```
js-grpc-web/
├── flake.nix              # Nix flake configuration for bufrnix
├── buf.yaml               # Buf configuration
├── proto/                 # Protocol buffer definitions
│   ├── user.proto        # User service with CRUD operations
│   └── chat.proto        # Chat service with streaming
├── src/
│   ├── server.ts         # gRPC server implementation
│   └── client.ts         # gRPC-Web client examples
├── envoy.yaml            # Envoy proxy configuration
├── package.json          # Node.js dependencies
└── tsconfig.json         # TypeScript configuration
```

## Getting Started

### 1. Enter the development shell

```bash
nix develop
```

This provides all necessary tools including Node.js, TypeScript, buf, protoc, and Envoy.

### 2. Generate protobuf code

```bash
nix build
```

This uses bufrnix to generate TypeScript code with gRPC-Web support. The generated code will be in `proto/gen/js/`.

### 3. Install Node.js dependencies

```bash
npm install
```

### 4. Run the gRPC server

In one terminal:

```bash
npm run server
```

The server will start on port 50051 and provide both UserService and ChatService.

### 5. Run the Envoy proxy

In another terminal:

```bash
npm run proxy
```

Envoy will start on port 8080 and proxy gRPC-Web requests to the gRPC server.

### 6. Run the client examples

In a third terminal:

```bash
npm run client
```

This will run through various examples demonstrating:

- Creating, reading, updating, and deleting users
- Listing users with pagination
- Streaming users (server streaming)
- Joining chat rooms
- Sending and receiving chat messages
- Streaming chat messages in real-time

## Understanding the Code

### Server Implementation (`src/server.ts`)

The server implements two gRPC services:

1. **UserService**: A CRUD service for user management

   - `CreateUser`: Creates a new user
   - `GetUser`: Retrieves a user by ID
   - `ListUsers`: Lists users with pagination and filtering
   - `UpdateUser`: Updates user information
   - `DeleteUser`: Deletes a user
   - `StreamUsers`: Streams users matching a filter (server streaming)

2. **ChatService**: A real-time chat service
   - `SendMessage`: Sends a message to a room
   - `JoinRoom`: Joins a user to a chat room
   - `StreamMessages`: Streams messages from a room (server streaming)
   - `StreamChat`: Bidirectional streaming for real-time chat

### Client Implementation (`src/client.ts`)

The client demonstrates how to:

- Create gRPC-Web client instances
- Make unary RPC calls with proper error handling
- Handle server streaming responses
- Work with protocol buffer message types in TypeScript

### Envoy Configuration (`envoy.yaml`)

The Envoy proxy is configured to:

- Listen on port 8080 for HTTP/gRPC-Web requests
- Enable CORS for browser-based clients
- Use the gRPC-Web filter to translate between gRPC-Web and gRPC
- Forward requests to the gRPC server on port 50051

## Customization

### Modifying Proto Files

1. Edit the `.proto` files in the `proto/` directory
2. Run `nix build` to regenerate the code
3. Update your TypeScript code to use the new generated types

### Changing gRPC-Web Options

Edit the `flake.nix` file to modify gRPC-Web generation options:

```nix
languages.js = {
  enable = true;
  grpcWeb = {
    enable = true;
    importStyle = "typescript";  # or "commonjs", "closure"
    mode = "grpcweb";           # or "grpcwebtext"
  };
};
```

### Adding Browser Support

To use the client in a browser:

1. Create an HTML file that loads the client code
2. Use a bundler like Webpack or Vite to bundle the TypeScript code
3. Ensure the Envoy proxy is configured with appropriate CORS headers
4. Connect to the Envoy proxy URL from your browser application

## Troubleshooting

### Common Issues

1. **"Cannot find module" errors**: Make sure you've run `nix build` to generate the protobuf code
2. **Connection refused**: Ensure both the gRPC server and Envoy proxy are running
3. **CORS errors in browser**: Check that Envoy's CORS configuration matches your client's origin

### Debugging Tips

- Use `grpcurl` to test the gRPC server directly:
  ```bash
  grpcurl -plaintext localhost:50051 list
  ```
- Check Envoy logs for proxy-related issues
- Enable debug logging in the client by setting appropriate log levels

## Next Steps

- Add authentication using gRPC metadata
- Implement proper error handling and retries
- Add unit tests for both server and client
- Deploy to production with TLS/SSL support
- Create a web UI using React or Vue.js with the gRPC-Web client
