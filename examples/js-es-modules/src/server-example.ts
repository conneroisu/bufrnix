/**
 * Server Example using Connect-ES with Protobuf-ES
 *
 * This example demonstrates how to create a Connect server using the generated
 * service definitions with validation support.
 */

import { ConnectRouter, createPromiseClient } from "@connectrpc/connect";
import { createConnectTransport } from "@connectrpc/connect-node";
import { fastify } from "fastify";
import { fastifyConnectPlugin } from "@connectrpc/connect-fastify";
import { UserService } from "../proto/gen/js/example/user/v1/user_connect.js";
import {
  User,
  Role,
  CreateUserRequest,
  CreateUserResponse,
  GetUserRequest,
  UpdateUserRequest,
  ListUsersRequest,
  ListUsersResponse,
} from "../proto/gen/js/example/user/v1/user_pb.js";
import { createValidator } from "@bufbuild/protovalidate";

// In-memory storage for demo
const users = new Map<string, User>();
let validator: Awaited<ReturnType<typeof createValidator>> | null = null;

// Initialize validator
async function initValidator() {
  validator = await createValidator();
}

// Initialize with some sample data
function initializeSampleData() {
  // Add sample users
  const sampleUsers = [
    new User({
      id: "user-1",
      email: "alice@example.com",
      name: "Alice Johnson",
      role: Role.ADMIN,
      createdAt: BigInt(Date.now()),
      profile: {
        bio: "System administrator",
        avatarUrl: "https://example.com/alice.jpg",
        location: "New York, NY",
        preferences: {
          theme: "dark",
          notifications: "enabled",
        },
      },
    }),
    new User({
      id: "user-2",
      email: "bob@example.com",
      name: "Bob Smith",
      role: Role.USER,
      createdAt: BigInt(Date.now()),
      profile: {
        bio: "Software developer",
        location: "San Francisco, CA",
      },
    }),
  ];

  sampleUsers.forEach((user) => users.set(user.id, user));
}

// Implement UserService with validation
const userServiceImpl: typeof UserService = {
  async createUser(req: CreateUserRequest): Promise<CreateUserResponse> {
    if (!req.user) {
      throw new Error("User data is required");
    }

    // Validate the user data
    if (validator) {
      const violations = await validator.validate(req.user);
      if (violations.length > 0) {
        throw new Error(
          `Validation failed: ${violations.map((v) => v.message).join(", ")}`,
        );
      }
    }

    const user = req.user.clone();
    if (!user.id) {
      user.id = `user-${Date.now()}`; // Generate ID
    }
    user.createdAt = BigInt(Date.now());

    users.set(user.id, user);
    return new CreateUserResponse({ user });
  },

  async getUser(req: GetUserRequest): Promise<User> {
    const user = users.get(req.id);
    if (!user) {
      throw new Error(`User ${req.id} not found`);
    }
    return user;
  },

  async updateUser(req: UpdateUserRequest): Promise<User> {
    if (!req.user || !req.user.id) {
      throw new Error("User with ID is required");
    }

    // Validate the updated user data
    if (validator) {
      const violations = await validator.validate(req.user);
      if (violations.length > 0) {
        throw new Error(
          `Validation failed: ${violations.map((v) => v.message).join(", ")}`,
        );
      }
    }

    const existing = users.get(req.user.id);
    if (!existing) {
      throw new Error(`User ${req.user.id} not found`);
    }

    users.set(req.user.id, req.user);
    return req.user;
  },

  async listUsers(req: ListUsersRequest): Promise<ListUsersResponse> {
    let userList = Array.from(users.values());

    // Apply role filter if specified
    if (req.roleFilter !== undefined && req.roleFilter !== Role.UNSPECIFIED) {
      userList = userList.filter((u) => u.role === req.roleFilter);
    }

    // Simple pagination
    const start = req.pageToken ? parseInt(req.pageToken) : 0;
    const pageSize = req.pageSize || 10;
    const paginatedUsers = userList.slice(start, start + pageSize);

    return new ListUsersResponse({
      users: paginatedUsers,
      nextPageToken:
        start + pageSize < userList.length ? String(start + pageSize) : "",
    });
  },
};

// Create the Connect router
export function createRouter(): ConnectRouter {
  return (router) => {
    router.service(UserService, userServiceImpl);
  };
}

// Start the server
async function startServer() {
  await initValidator();
  initializeSampleData();

  const server = fastify();

  await server.register(fastifyConnectPlugin, {
    routes: createRouter(),
  });

  const port = 8080;
  await server.listen({ port, host: "0.0.0.0" });

  console.log(
    "🚀 Connect-ES server with Protobuf-ES running on http://localhost:8080",
  );
  console.log("\nAvailable services:");
  console.log("  - UserService (with validation)");
  console.log("\nFeatures:");
  console.log("  ✅ TypeScript-first with Protobuf-ES");
  console.log("  ✅ Runtime validation with protovalidate");
  console.log("  ✅ Modern Connect protocol");
  console.log("\nTry using buf curl to test the services:");
  console.log(
    `  buf curl --data '{"user":{"email":"test@example.com","name":"Test User","role":"ROLE_USER"}}' \\`,
  );
  console.log(
    `    http://localhost:8080/example.user.v1.UserService/CreateUser`,
  );
}

// Only start server if this file is run directly
if (import.meta.url === `file://${process.argv[1]}`) {
  startServer().catch(console.error);
}

export { userServiceImpl };
