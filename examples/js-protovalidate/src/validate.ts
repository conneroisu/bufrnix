import { createValidator } from "@bufbuild/protovalidate";
import {
  User,
  CreateUserRequest,
  UserStatus,
  Profile,
} from "../proto/gen/js/example/v1/user_pb";

async function main() {
  // Create a validator
  const validator = await createValidator();

  console.log("JavaScript/TypeScript protovalidate-es Example");
  console.log("==============================================\n");

  // Example 1: Valid user
  console.log("1. Testing valid user:");
  const validUser = new User({
    id: "550e8400-e29b-41d4-a716-446655440000",
    email: "john.doe@example.com",
    username: "john_doe",
    age: 25,
    status: UserStatus.ACTIVE,
    tags: ["developer", "typescript"],
    profile: new Profile({
      bio: "Full-stack developer",
      website: "https://example.com",
      phone: "+1234567890",
    }),
  });

  try {
    const violations = await validator.validate(validUser);
    if (violations.length === 0) {
      console.log("✅ Valid user passed validation!");
    } else {
      console.log("❌ Unexpected validation errors:", violations);
    }
  } catch (error) {
    console.error("Error during validation:", error);
  }

  // Example 2: Invalid email
  console.log("\n2. Testing invalid email:");
  const invalidEmailUser = new User({
    id: "550e8400-e29b-41d4-a716-446655440000",
    email: "not-an-email",
    username: "john_doe",
    age: 25,
    status: UserStatus.ACTIVE,
  });

  try {
    const violations = await validator.validate(invalidEmailUser);
    if (violations.length > 0) {
      console.log("❌ Validation failed as expected:");
      violations.forEach((v) => {
        console.log(`   - Field: ${v.fieldPath}`);
        console.log(`     Message: ${v.message}`);
      });
    }
  } catch (error) {
    console.error("Error during validation:", error);
  }

  // Example 3: Invalid username (too short)
  console.log("\n3. Testing invalid username:");
  const invalidUsernameUser = new User({
    id: "550e8400-e29b-41d4-a716-446655440000",
    email: "john@example.com",
    username: "jd", // Too short
    age: 25,
    status: UserStatus.ACTIVE,
  });

  try {
    const violations = await validator.validate(invalidUsernameUser);
    if (violations.length > 0) {
      console.log("❌ Validation failed as expected:");
      violations.forEach((v) => {
        console.log(`   - Field: ${v.fieldPath}`);
        console.log(`     Message: ${v.message}`);
      });
    }
  } catch (error) {
    console.error("Error during validation:", error);
  }

  // Example 4: Invalid age
  console.log("\n4. Testing invalid age:");
  const invalidAgeUser = new User({
    id: "550e8400-e29b-41d4-a716-446655440000",
    email: "john@example.com",
    username: "john_doe",
    age: 15, // Too young
    status: UserStatus.ACTIVE,
  });

  try {
    const violations = await validator.validate(invalidAgeUser);
    if (violations.length > 0) {
      console.log("❌ Validation failed as expected:");
      violations.forEach((v) => {
        console.log(`   - Field: ${v.fieldPath}`);
        console.log(`     Message: ${v.message}`);
      });
    }
  } catch (error) {
    console.error("Error during validation:", error);
  }

  // Example 5: CreateUserRequest with weak password
  console.log("\n5. Testing CreateUserRequest with weak password:");
  const createRequest = new CreateUserRequest({
    user: validUser,
    password: "weak", // Too short and doesn't meet complexity requirements
  });

  try {
    const violations = await validator.validate(createRequest);
    if (violations.length > 0) {
      console.log("❌ Validation failed as expected:");
      violations.forEach((v) => {
        console.log(`   - Field: ${v.fieldPath}`);
        console.log(`     Message: ${v.message}`);
      });
    }
  } catch (error) {
    console.error("Error during validation:", error);
  }

  // Example 6: Valid CreateUserRequest
  console.log("\n6. Testing valid CreateUserRequest:");
  const validCreateRequest = new CreateUserRequest({
    user: validUser,
    password: "StrongPass123!", // Meets all requirements
  });

  try {
    const violations = await validator.validate(validCreateRequest);
    if (violations.length === 0) {
      console.log("✅ Valid CreateUserRequest passed validation!");
    } else {
      console.log("❌ Unexpected validation errors:", violations);
    }
  } catch (error) {
    console.error("Error during validation:", error);
  }

  console.log("\n✨ protovalidate-es example completed!");
}

main().catch(console.error);
