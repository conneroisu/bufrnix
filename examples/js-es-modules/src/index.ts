/**
 * JavaScript ES Modules Example for Bufrnix
 *
 * This example demonstrates how to use the generated protobuf code
 * with ES modules in TypeScript/JavaScript.
 */

import {
  User,
  Role,
  UserProfile,
  CreateUserRequest,
} from "./generated/example/user/v1/user_pb.js";
import {
  Product,
  Category,
  SearchProductsRequest,
} from "./generated/example/product/v1/product_pb.js";
import { Timestamp } from "@bufbuild/protobuf";

// Example 1: Creating and working with User messages
function userExample() {
  console.log("=== User Message Example ===\n");

  // Create a new user profile
  const profile = new UserProfile({
    bio: "Software developer passionate about distributed systems",
    avatarUrl: "https://example.com/avatar.jpg",
    location: "San Francisco, CA",
    preferences: {
      theme: "dark",
      language: "en",
      notifications: "email",
    },
  });

  // Create a new user
  const user = new User({
    id: "user-123",
    email: "john.doe@example.com",
    name: "John Doe",
    role: Role.ADMIN,
    createdAt: BigInt(Date.now()),
    profile: profile,
  });

  console.log("Created user:");
  console.log(`ID: ${user.id}`);
  console.log(`Email: ${user.email}`);
  console.log(`Name: ${user.name}`);
  console.log(`Role: ${Role[user.role]}`);
  console.log(`Created: ${new Date(Number(user.createdAt)).toISOString()}`);

  if (user.profile) {
    console.log("\nProfile:");
    console.log(`Bio: ${user.profile.bio}`);
    console.log(`Location: ${user.profile.location}`);
    console.log("Preferences:", Object.fromEntries(user.profile.preferences));
  }

  // Serialize to binary
  const bytes = user.toBinary();
  console.log(`\nSerialized size: ${bytes.length} bytes`);

  // Deserialize from binary
  const deserializedUser = User.fromBinary(bytes);
  console.log(`Deserialized user ID: ${deserializedUser.id}`);

  // Create a service request
  const createRequest = new CreateUserRequest({
    user: user,
  });

  // Convert to JSON
  const json = createRequest.toJson();
  console.log("\nJSON representation:", JSON.stringify(json, null, 2));
}

// Example 2: Working with Product messages and timestamps
function productExample() {
  console.log("\n\n=== Product Message Example ===\n");

  const now = Timestamp.now();

  // Create a product with images
  const product = new Product({
    id: "prod-456",
    name: "Wireless Headphones",
    description: "High-quality wireless headphones with noise cancellation",
    priceCents: BigInt(9999), // $99.99
    currency: "USD",
    stockQuantity: 50,
    category: Category.ELECTRONICS,
    tags: ["audio", "wireless", "bluetooth", "noise-cancelling"],
    images: [
      {
        url: "https://example.com/headphones-1.jpg",
        altText: "Wireless headphones front view",
        isPrimary: true,
      },
      {
        url: "https://example.com/headphones-2.jpg",
        altText: "Wireless headphones side view",
        isPrimary: false,
      },
    ],
    createdAt: now,
    updatedAt: now,
  });

  console.log("Created product:");
  console.log(`ID: ${product.id}`);
  console.log(`Name: ${product.name}`);
  console.log(
    `Price: $${Number(product.priceCents) / 100} ${product.currency}`,
  );
  console.log(`Category: ${Category[product.category]}`);
  console.log(`Stock: ${product.stockQuantity} units`);
  console.log(`Tags: ${product.tags.join(", ")}`);
  console.log(`Images: ${product.images.length}`);
  console.log(`Created: ${product.createdAt?.toDate().toISOString()}`);

  // Create a search request
  const searchRequest = new SearchProductsRequest({
    query: "wireless",
    category: Category.ELECTRONICS,
    minPriceCents: BigInt(5000), // $50
    maxPriceCents: BigInt(20000), // $200
    pageSize: 10,
    pageToken: "",
  });

  console.log("\nSearch request:");
  console.log(`Query: "${searchRequest.query}"`);
  console.log(
    `Category filter: ${searchRequest.category ? Category[searchRequest.category] : "none"}`,
  );
  console.log(
    `Price range: $${Number(searchRequest.minPriceCents) / 100} - $${Number(searchRequest.maxPriceCents) / 100}`,
  );
}

// Example 3: Working with enums and optional fields
function enumAndOptionalExample() {
  console.log("\n\n=== Enums and Optional Fields Example ===\n");

  // Iterate through all roles
  console.log("Available roles:");
  for (const [name, value] of Object.entries(Role)) {
    if (typeof value === "number") {
      console.log(`  ${name}: ${value}`);
    }
  }

  // Create users with different roles
  const users = [
    new User({
      id: "1",
      email: "user@example.com",
      name: "Regular User",
      role: Role.USER,
    }),
    new User({
      id: "2",
      email: "admin@example.com",
      name: "Admin",
      role: Role.ADMIN,
    }),
    new User({
      id: "3",
      email: "mod@example.com",
      name: "Moderator",
      role: Role.MODERATOR,
    }),
  ];

  console.log("\nUsers by role:");
  users.forEach((user) => {
    console.log(`  ${user.name} (${user.email}): ${Role[user.role]}`);
  });

  // Working with optional fields
  const userWithoutProfile = new User({
    id: "4",
    email: "minimal@example.com",
    name: "Minimal User",
    role: Role.USER,
    // profile is optional and not set
  });

  console.log("\nUser without profile:");
  console.log(`Has profile: ${userWithoutProfile.profile !== undefined}`);
}

// Example 4: Message cloning and modification
function messageManipulationExample() {
  console.log("\n\n=== Message Manipulation Example ===\n");

  // Create original product
  const original = new Product({
    id: "original-123",
    name: "Original Product",
    priceCents: BigInt(1000),
    stockQuantity: 10,
    category: Category.ELECTRONICS,
  });

  // Clone and modify
  const modified = original.clone();
  modified.name = "Modified Product";
  modified.priceCents = BigInt(1500);
  modified.stockQuantity = 20;

  console.log("Original:", {
    name: original.name,
    price: Number(original.priceCents),
    stock: original.stockQuantity,
  });

  console.log("Modified:", {
    name: modified.name,
    price: Number(modified.priceCents),
    stock: modified.stockQuantity,
  });

  // Check equality
  console.log(`\nMessages are equal: ${original.equals(modified)}`);
}

// Run all examples
async function main() {
  console.log("Bufrnix JavaScript ES Modules Example\n");
  console.log(
    "This example demonstrates working with generated protobuf code.\n",
  );

  userExample();
  productExample();
  enumAndOptionalExample();
  messageManipulationExample();

  console.log("\n\n=== Example Complete ===");
}

// Run the examples
main().catch(console.error);
