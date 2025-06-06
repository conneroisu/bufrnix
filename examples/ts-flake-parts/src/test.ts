/**
 * TypeScript Test Suite for Flake-Parts Example
 * 
 * Basic test suite demonstrating testing generated protobuf code
 * and validating the Bufrnix + flake-parts integration.
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

// Simple test framework
interface TestResult {
  name: string;
  passed: boolean;
  error?: string;
}

const results: TestResult[] = [];

function test(name: string, testFn: () => void | Promise<void>): void {
  console.log(`🧪 Running test: ${name}`);
  
  try {
    const result = testFn();
    if (result instanceof Promise) {
      result
        .then(() => {
          results.push({ name, passed: true });
          console.log(`✅ ${name}`);
        })
        .catch((error) => {
          results.push({ name, passed: false, error: error.message });
          console.log(`❌ ${name}: ${error.message}`);
        });
    } else {
      results.push({ name, passed: true });
      console.log(`✅ ${name}`);
    }
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    results.push({ name, passed: false, error: errorMessage });
    console.log(`❌ ${name}: ${errorMessage}`);
  }
}

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEqual<T>(actual: T, expected: T, message: string): void {
  if (actual !== expected) {
    throw new Error(`${message}: expected ${expected}, got ${actual}`);
  }
}

// Test 1: User message creation and basic properties
test("User message creation and properties", () => {
  const user = create(UserSchema, {
    id: "test-123",
    email: "test@example.com",
    name: "Test User",
    role: Role.USER,
    isActive: true,
    createdAt: Timestamp.now(),
  });

  assert(user.id === "test-123", "User ID should be set correctly");
  assert(user.email === "test@example.com", "User email should be set correctly");
  assert(user.name === "Test User", "User name should be set correctly");
  assert(user.role === Role.USER, "User role should be set correctly");
  assert(user.isActive === true, "User active status should be set correctly");
  assert(user.createdAt !== undefined, "User createdAt should be set");
});

// Test 2: Enum values and type safety
test("Enum values and type safety", () => {
  const roles = [Role.ADMIN, Role.USER, Role.MODERATOR];
  
  assert(typeof Role.ADMIN === "number", "Role enum should be numeric");
  assert(typeof Role.USER === "number", "Role enum should be numeric");
  assert(typeof Role.MODERATOR === "number", "Role enum should be numeric");
  
  // Test that enum values are distinct
  const uniqueRoles = new Set(roles);
  assert(uniqueRoles.size === roles.length, "All role values should be unique");
  
  // Test role names
  assert(Role[Role.ADMIN] === "ADMIN", "Role.ADMIN should have correct name");
  assert(Role[Role.USER] === "USER", "Role.USER should have correct name");
  assert(Role[Role.MODERATOR] === "MODERATOR", "Role.MODERATOR should have correct name");
});

// Test 3: Message serialization and deserialization
test("Message serialization and deserialization", () => {
  const originalUser = create(UserSchema, {
    id: "serialize-test",
    email: "serialize@example.com",
    name: "Serialize Test",
    role: Role.ADMIN,
    isActive: true,
  });

  // Test binary serialization
  const binaryData = originalUser.toBinary();
  assert(binaryData instanceof Uint8Array, "toBinary should return Uint8Array");
  assert(binaryData.length > 0, "Binary data should not be empty");

  // Test binary deserialization
  const deserializedUser = UserSchema.fromBinary(binaryData);
  assert(deserializedUser.id === originalUser.id, "Deserialized ID should match");
  assert(deserializedUser.email === originalUser.email, "Deserialized email should match");
  assert(deserializedUser.name === originalUser.name, "Deserialized name should match");
  assert(deserializedUser.role === originalUser.role, "Deserialized role should match");
  assert(deserializedUser.isActive === originalUser.isActive, "Deserialized active status should match");

  // Test JSON serialization
  const jsonData = originalUser.toJson();
  assert(typeof jsonData === "object", "toJSON should return object");
  assert(jsonData.id === originalUser.id, "JSON ID should match");
  assert(jsonData.email === originalUser.email, "JSON email should match");

  // Test JSON deserialization
  const fromJsonUser = UserSchema.fromJson(jsonData);
  assert(fromJsonUser.id === originalUser.id, "From JSON ID should match");
  assert(fromJsonUser.email === originalUser.email, "From JSON email should match");
});

// Test 4: Message cloning and equality
test("Message cloning and equality", () => {
  const originalUser = create(UserSchema, {
    id: "clone-test",
    email: "clone@example.com",
    name: "Clone Test",
    role: Role.USER,
    isActive: true,
  });

  // Test cloning
  const clonedUser = UserSchema.clone(originalUser);
  assert(UserSchema.equals(clonedUser, originalUser), "Cloned user should equal original");
  assert(clonedUser !== originalUser, "Cloned user should be different object");

  // Test that modifying clone doesn't affect original
  clonedUser.name = "Modified Clone";
  assert(!UserSchema.equals(clonedUser, originalUser), "Modified clone should not equal original");
  assert(originalUser.name === "Clone Test", "Original name should be unchanged");
  assert(clonedUser.name === "Modified Clone", "Clone name should be changed");
});

// Test 5: Service request messages
test("Service request messages", () => {
  const user = create(UserSchema, {
    id: "service-test",
    email: "service@example.com",
    name: "Service Test",
    role: Role.USER,
    isActive: true,
  });

  // Test CreateUserRequest
  const createRequest = create(CreateUserRequestSchema, {
    user: user,
  });
  assert(createRequest.user !== undefined, "CreateUserRequest should have user");
  assert(createRequest.user?.id === user.id, "CreateUserRequest user ID should match");

  // Test GetUserRequest
  const getRequest = create(GetUserRequestSchema, {
    id: user.id,
  });
  assert(getRequest.id === user.id, "GetUserRequest ID should be set correctly");

  // Test ListUsersRequest
  const listRequest = create(ListUsersRequestSchema, {
    pageSize: 10,
    pageToken: "",
    filter: "role:USER",
  });
  assert(listRequest.pageSize === 10, "ListUsersRequest pageSize should be set correctly");
  assert(listRequest.pageToken === "", "ListUsersRequest pageToken should be set correctly");
  assert(listRequest.filter === "role:USER", "ListUsersRequest filter should be set correctly");
});

// Test 6: Optional fields and default values
test("Optional fields and default values", () => {
  // Create user with minimal fields
  const minimalUser = create(UserSchema, {
    id: "minimal-test",
    email: "minimal@example.com",
    name: "Minimal User",
    role: Role.USER,
  });

  assert(minimalUser.id === "minimal-test", "Minimal user ID should be set");
  assert(minimalUser.email === "minimal@example.com", "Minimal user email should be set");
  assert(minimalUser.name === "Minimal User", "Minimal user name should be set");
  assert(minimalUser.role === Role.USER, "Minimal user role should be set");
  
  // Test default values for optional fields
  assert(minimalUser.isActive === false, "Default isActive should be false");
  assert(minimalUser.createdAt === undefined, "Default createdAt should be undefined");
  assert(minimalUser.updatedAt === undefined, "Default updatedAt should be undefined");
});

// Test 7: Timestamp handling
test("Timestamp handling", () => {
  const now = new Date();
  const timestamp = Timestamp.fromDate(now);
  
  const user = create(UserSchema, {
    id: "timestamp-test",
    email: "timestamp@example.com",
    name: "Timestamp Test",
    role: Role.USER,
    createdAt: timestamp,
  });

  assert(user.createdAt !== undefined, "User should have createdAt timestamp");
  
  // Test timestamp conversion back to Date
  const convertedDate = user.createdAt?.toDate();
  assert(convertedDate instanceof Date, "Timestamp should convert to Date");
  
  // Test that the dates are close (within 1 second)
  const timeDiff = Math.abs(convertedDate!.getTime() - now.getTime());
  assert(timeDiff < 1000, "Converted date should be close to original");
});

// Main test runner
async function runTests() {
  console.log("🧪 TypeScript Flake-Parts Test Suite\n");
  console.log("Testing generated protobuf code and integration...\n");

  // Run all tests (they're already queued)
  
  // Wait a bit for any async tests to complete
  await new Promise(resolve => setTimeout(resolve, 100));

  // Report results
  console.log("\n📊 Test Results:");
  console.log("================");

  const passed = results.filter(r => r.passed).length;
  const failed = results.filter(r => !r.passed).length;

  console.log(`✅ Passed: ${passed}`);
  console.log(`❌ Failed: ${failed}`);
  console.log(`📈 Total: ${results.length}`);

  if (failed > 0) {
    console.log("\n❌ Failed Tests:");
    results.filter(r => !r.passed).forEach(result => {
      console.log(`   • ${result.name}: ${result.error}`);
    });
    process.exit(1);
  } else {
    console.log("\n🎉 All tests passed!");
    console.log("Bufrnix with flake-parts generates working TypeScript code!");
  }
}

// Export test functions for external use
export {
  test,
  assert,
  assertEqual,
  runTests,
};

// Run tests if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  runTests().catch(console.error);
}