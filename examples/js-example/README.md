# JavaScript Example for Bufrnix

This example demonstrates how to use Bufrnix to generate JavaScript/TypeScript code from Protocol Buffers with various output formats.

## Features

- Standard JavaScript output (CommonJS format)
- Modern ECMAScript modules
- Multiple RPC options:
  - Connect-ES (modern RPC)
  - gRPC-Web (browser-compatible RPC)
- TypeScript compatibility
- Basic user service example

## Usage

1. Enter the Nix development shell:

```shell
nix develop
```

2. Generate the Protocol Buffer code:

```shell
nix build
```

This will generate various JavaScript formats in the `proto/gen/js` directory.

3. Install Node.js dependencies:

```shell
npm install
```

4. Build the TypeScript code:

```shell
npm run build
```

5. Run the example:

```shell
npm start
```

## Generated Files

After code generation, you'll see the following structure:

```
proto/gen/js/
├── example/
│   └── v1/
│       ├── example_pb.js               # Standard JavaScript (CommonJS)
│       ├── example.js                  # ECMAScript modules
│       ├── example_connect.js          # Connect-ES RPC client
│       ├── example_grpc_web_pb.js      # gRPC-Web client
│       └── example-ConnectClient.js    # Connect client for modern browsers
```

## Protoc Plugins Used

This example demonstrates the following protoc plugins:

1. **protoc-gen-js** - Standard JavaScript output (built into protobuf)
2. **protoc-gen-es** - Modern ECMAScript modules
3. **protoc-gen-connect-es** - Modern RPC with Connect
4. **protoc-gen-grpc-web** - Browser-compatible RPC

## Configuration

The flake.nix file configures Bufrnix to use the following JavaScript options:

```nix
languages.js = {
  enable = true;
  outputPath = "proto/gen/js";
  packageName = "example-proto";

  # Modern JavaScript with ECMAScript modules
  es.enable = true;

  # Modern RPC with Connect-ES
  connect.enable = true;

  # Browser-compatible RPC with gRPC-Web
  grpcWeb.enable = true;
};
```

## Notes

- The example includes placeholder code that would use the generated files
- Uncomment the import statements and client code after generating the protobuf files
- Choose the import style that matches your project's needs (CommonJS or ES modules)
