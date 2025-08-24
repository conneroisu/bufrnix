# JavaScript/TypeScript Annotations Example

This example demonstrates how to generate TypeScript code from Protocol Buffer definitions that include Google API annotations for HTTP/REST endpoint mapping.

## What This Example Shows

- **Google API Annotations**: How to use `google.api.http` annotations to map gRPC services to HTTP/REST endpoints
- **TypeScript Generation**: Modern TypeScript code generation using Protobuf-ES  
- **Type Safety**: Full TypeScript type safety for protobuf messages and services
- **HTTP/REST Mapping**: Automatic HTTP endpoint generation from proto annotations
- **Real-world Service**: Complete user management service with CRUD operations

## Key Features

✅ **Google API annotations** (`google.api.http`) for REST endpoints  
✅ **Protobuf-ES** for modern TypeScript message generation  
✅ **Type-safe** protobuf messages and service interfaces  
✅ **HTTP/REST mapping** from gRPC service definitions  
✅ **Complete example** with user management service  
✅ **ES modules** support with proper import/export  

## Generated Code Structure

After running `nix build`, you'll get:

```
gen/ts/
├── google/api/           # Google API annotations as TypeScript
│   ├── annotations_pb.ts
│   └── http_pb.ts
└── example/v1/          # Your service definitions
    └── user_service_pb.ts
```

## Protocol Buffer Definition

The example uses a comprehensive user service (`proto/example/v1/user_service.proto`) with:

- **User Management**: CRUD operations for users
- **HTTP Mappings**: Each RPC method mapped to RESTful HTTP endpoints
- **Rich Data Types**: Nested messages, enums, and maps
- **Best Practices**: Proper field naming, pagination, filtering

### Sample Service Definition

```protobuf
service UserService {
  // GET /api/v1/users/{user_id}
  rpc GetUser(GetUserRequest) returns (GetUserResponse) {
    option (google.api.http) = {
      get: "/api/v1/users/{user_id}"
    };
  }
  
  // POST /api/v1/users
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse) {
    option (google.api.http) = {
      post: "/api/v1/users"
      body: "user"
    };
  }
}
```

## Quick Start

### 1. Generate TypeScript Code

```bash
nix build
```

This generates TypeScript files with:
- Message types and interfaces
- Service definitions  
- Google API annotations
- Full type safety

### 2. Install Dependencies

```bash
npm install
```

### 3. Run the Example

```bash
npm run dev
```

This demonstrates:
- Creating and manipulating protobuf messages
- Type-safe message construction
- How generated interfaces work

### 4. Build for Production

```bash
npm run build
npm start
```

## Generated TypeScript Usage

### Message Creation

```typescript
import { User, UserStatus, UserProfile } from "./gen/ts/example/v1/user_service_pb.js";

// Create type-safe protobuf messages
const user: User = {
  id: "user_123",
  email: "alice@example.com", 
  name: "Alice Johnson",
  status: UserStatus.USER_STATUS_ACTIVE,
  profile: {
    firstName: "Alice",
    lastName: "Johnson",
    bio: "Software engineer",
    interests: ["typescript", "protobuf"]
  },
  roles: ["developer"],
  createdAt: BigInt(Date.now())
};
```

### HTTP/REST Mapping

The Google API annotations automatically map to HTTP endpoints:

- `GetUser({user_id: "123"})` → `GET /api/v1/users/123`
- `ListUsers({page_size: 10})` → `GET /api/v1/users?page_size=10`
- `CreateUser({user: {...}})` → `POST /api/v1/users` with JSON body
- `UpdateUser({user: {...}})` → `PUT /api/v1/users/123` with JSON body  
- `DeleteUser({user_id: "123"})` → `DELETE /api/v1/users/123`

## File Structure

```
js-annotations/
├── flake.nix                 # Nix build configuration
├── package.json              # Node.js dependencies and scripts
├── tsconfig.json            # TypeScript compiler configuration
├── proto/
│   ├── google/api/          # Google API proto definitions
│   │   ├── annotations.proto
│   │   └── http.proto
│   └── example/v1/
│       └── user_service.proto # Main service definition
├── src/
│   └── index.ts             # Example TypeScript code
└── gen/ts/                  # Generated TypeScript files (after build)
    ├── google/api/
    └── example/v1/
```

## Development Commands

```bash
# Generate TypeScript from proto files
nix build

# Install dependencies  
npm install

# Run in development mode
npm run dev

# Build TypeScript
npm run build

# Run compiled JavaScript
npm start

# Type checking without compilation
npm run type-check

# Lint the code
npm run lint

# Clean generated files
npm run clean
```

## Advanced Features

### Protobuf-ES Benefits

- **Modern TypeScript**: Uses contemporary TypeScript patterns
- **Tree Shaking**: Only import what you use
- **ES Modules**: Native ES module support
- **Type Safety**: Full TypeScript integration
- **Performance**: Efficient serialization/deserialization

### Google API Annotations

The example demonstrates various HTTP mapping patterns:

- **Path Parameters**: `{user_id}` in URLs
- **Query Parameters**: Automatic mapping from request fields
- **Request Bodies**: JSON body mapping with `body: "user"`
- **HTTP Methods**: GET, POST, PUT, DELETE
- **Batch Operations**: Custom endpoints like `:batchGet`

## Use Cases

This example is perfect for:

- **Web APIs**: Building HTTP/REST APIs from gRPC definitions
- **Full-Stack Applications**: Sharing types between frontend and backend
- **Microservices**: Type-safe inter-service communication
- **API Gateways**: Converting between gRPC and HTTP protocols
- **Documentation**: Auto-generating API documentation from proto files

## Next Steps

- Explore the generated TypeScript files in `gen/ts/`
- Try modifying the proto file and regenerating
- Add validation using protobuf validation rules
- Integrate with a real HTTP server or gRPC service
- Use Connect-ES to create actual client implementations

## Resources

- [Bufrnix Documentation](https://conneroisu.github.io/bufrnix/)
- [Protobuf-ES](https://github.com/bufbuild/protobuf-es) - Modern TypeScript protobuf library
- [Google API Design Guide](https://cloud.google.com/apis/design) - Best practices for API design
- [Connect-ES](https://github.com/connectrpc/connect-es) - Type-safe clients for browsers and Node.js