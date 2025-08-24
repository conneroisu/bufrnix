/**
 * Example demonstrating usage of generated TypeScript code from protobuf
 * definitions with Google API annotations.
 * 
 * This example shows:
 * 1. How to create and use protobuf messages
 * 2. How the generated TypeScript interfaces work
 * 3. How Connect-ES enables both gRPC and HTTP/REST clients
 */

// Import generated TypeScript types and functions
// These will be available after running `nix build` or `nix run`
import { 
  User,
  UserStatus, 
  UserProfile,
  GetUserRequest,
  GetUserResponse,
  ListUsersRequest,
  CreateUserRequest
} from "../gen/ts/example/v1/user_service_pb.js";

/**
 * Example function demonstrating how to create and manipulate
 * protobuf messages using the generated TypeScript code.
 */
function demonstrateProtobufUsage() {
  console.log("🚀 Protobuf TypeScript Generation Example");
  console.log("==========================================\n");

  // Create a user profile
  const profile: UserProfile = {
    firstName: "Alice",
    lastName: "Johnson", 
    bio: "Software engineer passionate about distributed systems",
    avatarUrl: "https://example.com/avatars/alice.jpg",
    location: "San Francisco, CA",
    timezone: "America/Los_Angeles",
    language: "en-US",
    interests: ["typescript", "protobuf", "grpc", "rest-apis"]
  };

  // Create a user with the profile
  const user: User = {
    id: "user_12345",
    email: "alice.johnson@example.com",
    name: "Alice Johnson",
    status: UserStatus.USER_STATUS_ACTIVE,
    profile: profile,
    roles: ["developer", "tech-lead"],
    metadata: {
      "department": "engineering",
      "team": "backend",
      "hire_date": "2023-01-15"
    },
    createdAt: BigInt(Date.now() - 86400000), // 1 day ago
    updatedAt: BigInt(Date.now())
  };

  console.log("✅ Created User object:");
  console.log(JSON.stringify(user, (key, value) =>
    typeof value === 'bigint' ? value.toString() : value, 2));
  console.log();

  // Create request objects
  const getUserRequest: GetUserRequest = {
    userId: "user_12345",
    fields: ["id", "email", "name", "status", "profile"]
  };

  console.log("✅ Created GetUserRequest:");
  console.log(JSON.stringify(getUserRequest, null, 2));
  console.log();

  const listUsersRequest: ListUsersRequest = {
    pageSize: 10,
    pageToken: "",
    status: UserStatus.USER_STATUS_ACTIVE,
    roles: ["developer"],
    query: "alice",
    orderBy: "created_at"
  };

  console.log("✅ Created ListUsersRequest:");
  console.log(JSON.stringify(listUsersRequest, null, 2));
  console.log();

  const createUserRequest: CreateUserRequest = {
    user: user,
    password: "secure_password_123",
    sendWelcomeEmail: true
  };

  console.log("✅ Created CreateUserRequest:");
  console.log(JSON.stringify(createUserRequest, (key, value) =>
    key === 'password' ? '***REDACTED***' : 
    typeof value === 'bigint' ? value.toString() : value, 2));
  console.log();

  return { user, getUserRequest, listUsersRequest, createUserRequest };
}

/**
 * Example of how you would use Connect-ES to create clients
 * (This shows the pattern - the actual client would be generated)
 */
function demonstrateConnectESPattern() {
  console.log("🌐 Connect-ES Client Pattern Example");
  console.log("====================================\n");

  // With Connect-ES, you can create clients that work with both:
  // 1. gRPC (for high-performance server-to-server communication)
  // 2. HTTP/REST (for web browsers and general HTTP clients)

  console.log("📡 gRPC Client Pattern:");
  console.log(`
    import { createClient } from "@connectrpc/connect";
    import { createGrpcTransport } from "@connectrpc/connect-node";
    import { UserService } from "../gen/ts/example/v1/user_service_connect.js";

    const transport = createGrpcTransport({
      baseUrl: "https://api.example.com",
    });

    const client = createClient(UserService, transport);
    
    // Type-safe gRPC calls
    const user = await client.getUser({ userId: "user_123" });
    const users = await client.listUsers({ pageSize: 10 });
  `);

  console.log("🌐 HTTP/REST Client Pattern:");
  console.log(`
    import { createClient } from "@connectrpc/connect";
    import { createConnectTransport } from "@connectrpc/connect-web";
    import { UserService } from "../gen/ts/example/v1/user_service_connect.js";

    const transport = createConnectTransport({
      baseUrl: "https://api.example.com",
    });

    const client = createClient(UserService, transport);
    
    // Same TypeScript interface, but uses HTTP/REST under the hood:
    // GET /api/v1/users/user_123
    const user = await client.getUser({ userId: "user_123" });
    
    // GET /api/v1/users?page_size=10
    const users = await client.listUsers({ pageSize: 10 });
    
    // POST /api/v1/users (with JSON body)
    const newUser = await client.createUser({ 
      user: { name: "John Doe", email: "john@example.com" } 
    });
  `);

  console.log("✨ Key Benefits:");
  console.log("  • Same TypeScript interfaces for both protocols");
  console.log("  • Type safety at compile time");
  console.log("  • Automatic serialization/deserialization"); 
  console.log("  • HTTP endpoints defined by Google API annotations");
  console.log("  • Works in browsers, Node.js, and Deno");
  console.log();
}

/**
 * Main function to run the examples
 */
function main() {
  try {
    const examples = demonstrateProtobufUsage();
    demonstrateConnectESPattern();

    console.log("🎉 Example completed successfully!");
    console.log("\nTo see this in action:");
    console.log("1. Run `nix build` to generate TypeScript code");
    console.log("2. Run `npm install` to install dependencies");
    console.log("3. Run `npm run dev` to execute this example");
    console.log("4. Check the generated code in `./gen/ts/`");
    
  } catch (error) {
    console.error("❌ Error running example:", error);
    
    if (error instanceof Error && error.message.includes('Cannot resolve')) {
      console.log("\n💡 Tip: You may need to run `nix build` first to generate the TypeScript files.");
    }
    
    process.exit(1);
  }
}

// Run the example if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export { demonstrateProtobufUsage, demonstrateConnectESPattern };