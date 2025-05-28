/**
 * Client Example using Connect-ES with Protobuf-ES
 *
 * This example demonstrates how to create a Connect client that
 * communicates with the server using the generated service definitions.
 */

import { createPromiseClient } from "@connectrpc/connect";
import { createConnectTransport } from "@connectrpc/connect-node";
import { UserService } from "../proto/gen/js/example/user/v1/user_connect.js";
import {
  User,
  Role,
  CreateUserRequest,
  GetUserRequest,
  ListUsersRequest,
} from "../proto/gen/js/example/user/v1/user_pb.js";

// Create transport for the client
const transport = createConnectTransport({
  baseUrl: "http://localhost:8080",
  httpVersion: "1.1",
});

// Create a typed client
const client = createPromiseClient(UserService, transport);

async function demonstrateClient() {
  console.log("🔗 Connect-ES Client Example\n");

  try {
    // 1. Create a new user
    console.log("1. Creating a new user...");
    const createResponse = await client.createUser({
      user: new User({
        email: "john@example.com",
        name: "John Doe",
        role: Role.USER,
        profile: {
          bio: "Software engineer",
          location: "Seattle, WA",
          preferences: {
            theme: "light",
            language: "en",
          },
        },
      }),
    });
    console.log("✅ Created user:", createResponse.user?.id);
    console.log("   Name:", createResponse.user?.name);
    console.log("   Email:", createResponse.user?.email);

    // 2. Get the created user
    console.log("\n2. Fetching user by ID...");
    const user = await client.getUser({
      id: createResponse.user!.id,
    });
    console.log("✅ Retrieved user:", user.name);

    // 3. Update the user
    console.log("\n3. Updating user...");
    user.profile = {
      ...user.profile,
      bio: "Senior software engineer",
      avatarUrl: "https://example.com/john.jpg",
    };
    const updatedUser = await client.updateUser({ user });
    console.log("✅ Updated user bio:", updatedUser.profile?.bio);

    // 4. List all users
    console.log("\n4. Listing all users...");
    const listResponse = await client.listUsers({
      pageSize: 10,
    });
    console.log(`✅ Found ${listResponse.users.length} users:`);
    for (const u of listResponse.users) {
      console.log(`   - ${u.name} (${u.email}) - Role: ${Role[u.role]}`);
    }

    // 5. Filter users by role
    console.log("\n5. Listing admin users...");
    const adminResponse = await client.listUsers({
      roleFilter: Role.ADMIN,
      pageSize: 10,
    });
    console.log(`✅ Found ${adminResponse.users.length} admin users:`);
    for (const u of adminResponse.users) {
      console.log(`   - ${u.name} (${u.email})`);
    }

    // 6. Demonstrate validation error
    console.log("\n6. Testing validation (this should fail)...");
    try {
      await client.createUser({
        user: new User({
          email: "invalid-email", // Invalid email format
          name: "", // Empty name
          role: Role.UNSPECIFIED, // Invalid role
        }),
      });
    } catch (error) {
      console.log("❌ Validation failed as expected:", error.message);
    }
  } catch (error) {
    console.error("Error:", error);
  }
}

// Demonstrate type safety and schema evolution
async function demonstrateTypeSafety() {
  console.log("\n\n🔒 Type Safety Example");

  // The TypeScript compiler will catch these errors:
  // await client.createUser({ user: { invalidField: "test" } }); // ❌ Type error
  // await client.createUser({ user: new User({ email: 123 }) }); // ❌ Type error

  // Correct usage with full type safety:
  const request = new CreateUserRequest({
    user: new User({
      email: "type-safe@example.com",
      name: "Type Safe User",
      role: Role.USER,
    }),
  });

  console.log("✅ Type-safe request created successfully");
}

// Run the client demo
if (import.meta.url === `file://${process.argv[1]}`) {
  console.log("Make sure the server is running on http://localhost:8080");
  console.log("Run: npm run server\n");

  demonstrateClient()
    .then(() => demonstrateTypeSafety())
    .catch(console.error);
}
