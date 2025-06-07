/**
 * TypeScript Flake-Parts Example for Bufrnix
 *
 * This example demonstrates how to use Bufrnix with flake-parts
 * to generate TypeScript protobuf code with modern features.
 */

import {
  User,
  Role,
  UserSchema,
  CreateUserRequest,
  CreateUserRequestSchema,
  GetUserRequest,
  GetUserRequestSchema,
  ListUsersRequest,
  ListUsersRequestSchema,
} from "../gen/js/example/v1/user_pb.js";
import { Timestamp, create } from "@bufbuild/protobuf";

// Example 1: Working with generated TypeScript protobuf messages
function messageExample() {
  console.log("=== TypeScript Message Example ===\n");

  // Create a new user using Protobuf-ES v2 API
  const user = create(UserSchema, {
    id: "user-123",
    email: "john.doe@example.com",
    name: "John Doe",
    role: Role.ADMIN,
    createdAt: Timestamp.now(),
    isActive: true,
  });

  console.log("Created user:");
  console.log(`ID: ${user.id}`);
  console.log(`Email: ${user.email}`);
  console.log(`Name: ${user.name}`);
  console.log(`Role: ${Role[user.role]}`);
  console.log(`Active: ${user.isActive}`);
  console.log(`Created: ${user.createdAt?.toDate().toISOString()}`);

  // Serialize to binary
  const bytes = user.toBinary();
  console.log(`\nSerialized size: ${bytes.length} bytes`);

  // Deserialize from binary
  const deserializedUser = UserSchema.fromBinary(bytes);
  console.log(`Deserialized user ID: ${deserializedUser.id}`);

  // Convert to JSON
  const json = user.toJson();
  console.log("\nJSON representation:", JSON.stringify(json, null, 2));

  return user;
}

// Example 2: Working with service requests
function serviceRequestExample(user: User) {
  console.log("\n\n=== Service Request Example ===\n");

  // Create service requests using Protobuf-ES v2 API
  const createRequest = create(CreateUserRequestSchema, {
    user: user,
  });

  const getUserRequest = create(GetUserRequestSchema, {
    id: user.id,
  });

  const listUsersRequest = create(ListUsersRequestSchema, {
    pageSize: 10,
    pageToken: "",
    filter: "role:ADMIN",
  });

  console.log("Service requests created:");
  console.log(`Create user request: ${createRequest.user?.name}`);
  console.log(`Get user request: ${getUserRequest.id}`);
  console.log(`List users request: page size ${listUsersRequest.pageSize}`);

  return { createRequest, getUserRequest, listUsersRequest };
}

// Example 3: TypeScript type safety demonstration
function typeSafetyExample() {
  console.log("\n\n=== TypeScript Type Safety Example ===\n");

  // Demonstrate compile-time type safety
  const user = create(UserSchema, {
    id: "typed-user",
    email: "typed@example.com",
    name: "Typed User",
    role: Role.USER,
    // TypeScript ensures only valid fields are used
  });

  // Type-safe enum usage
  const roles: Role[] = [Role.ADMIN, Role.USER, Role.MODERATOR];
  console.log("Available roles:", roles.map(role => Role[role]));

  // Type-safe field access
  const userId: string = user.id;
  const userRole: Role = user.role;
  const isActive: boolean = user.isActive;

  console.log("Type-safe access:");
  console.log(`User ID (string): ${userId}`);
  console.log(`User role (enum): ${Role[userRole]}`);
  console.log(`Is active (boolean): ${isActive}`);

  return user;
}

// Example 4: Message cloning and immutability
function immutabilityExample() {
  console.log("\n\n=== Immutability Example ===\n");

  // Create original user
  const original = create(UserSchema, {
    id: "original-123",
    email: "original@example.com",
    name: "Original User",
    role: Role.USER,
    isActive: true,
  });

  // Clone and modify
  const modified = UserSchema.clone(original);
  modified.name = "Modified User";
  modified.role = Role.ADMIN;
  modified.isActive = false;

  console.log("Original user:", {
    name: original.name,
    role: Role[original.role],
    active: original.isActive,
  });

  console.log("Modified user:", {
    name: modified.name,
    role: Role[modified.role],
    active: modified.isActive,
  });

  // Check equality
  console.log(`\nMessages are equal: ${UserSchema.equals(original, modified)}`);
  console.log("This demonstrates proper message cloning and immutability");
}


// Main function to run all examples
function main() {
  console.log("🚀 Bufrnix TypeScript Flake-Parts Example\n");
  console.log("This example demonstrates:\n");
  console.log("• Flake-parts integration with Bufrnix");
  console.log("• TypeScript protobuf generation with Protobuf-ES");
  console.log("• Type safety and compile-time checking");
  console.log("• Modern ES modules support\n");

  try {
    const user = messageExample();
    serviceRequestExample(user);
    typeSafetyExample();
    immutabilityExample();

    console.log("\n\n✅ All examples completed successfully!");
    console.log("This demonstrates that Bufrnix with flake-parts generates");
    console.log("high-quality, type-safe TypeScript code from protobuf definitions.");

  } catch (error) {
    console.error("❌ Example failed:", error);
    process.exit(1);
  }
}

// Export for testing
export {
  messageExample,
  serviceRequestExample,
  typeSafetyExample,
  immutabilityExample,
};

// Run the examples if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}