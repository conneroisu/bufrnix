import { createClient } from "@connectrpc/connect";
import { createConnectTransport } from "@connectrpc/connect-web";

// Generated protobuf packages - ONLY frontend-relevant APIs
import {
  // Common types (shared with backend)
  User,
  UserStatus,
  UserProfile,
  PaginationRequest,
  ResponseStatus,
} from "../proto/generated/common/v1/types_pb.js";

import {
  // Public API services with Google annotations (frontend only)
  UserAPIService,
  GetUserRequest,
  GetUserResponse,
  ListUsersRequest,
  UpdateUserProfileRequest,
} from "../proto/generated/api/v1/user_api_pb.js";

import {
  // Authentication API with Google annotations (frontend only)
  AuthAPIService,
  LoginRequest,
  LogoutRequest,
  GetSessionRequest,
} from "../proto/generated/api/v1/auth_api_pb.js";

// Note: Google API annotations are imported automatically by the generated code
// These provide the HTTP/REST mappings for the Connect-ES client

console.log("🌐 JavaScript/TypeScript Frontend - Public APIs Only");
console.log("====================================================");
console.log("");
console.log("✅ Generated protobuf packages:");
console.log("  • common/v1     - Shared types with backend");
console.log("  • api/v1        - Public REST APIs with Google annotations");
console.log("  • google/api/*  - Google annotations for HTTP/REST mapping");
console.log("");
console.log("❌ NOT generated (correctly excluded):");
console.log("  • internal/v1/* - Internal gRPC services (backend only)");
console.log("  This prevents frontend access to backend-only operations");
console.log("");

// Create REST API clients using Connect-ES
// The Google API annotations automatically map these to HTTP endpoints:
//   - GetUser: GET /api/v1/users/{user_id}
//   - ListUsers: GET /api/v1/users
//   - Login: POST /api/v1/auth/login
const transport = createConnectTransport({
  baseUrl: "https://api.example.com",
});

const userClient = createClient(UserAPIService, transport);
const authClient = createClient(AuthAPIService, transport);

async function demonstrateTypeSafetyAndSmartGeneration() {
  console.log("🎯 Demonstrating Type-Safe API Calls");
  console.log("====================================");
  console.log("");

  // 1. Create sample data using shared types
  const sampleUser = new User({
    id: "user_12345",
    email: "alice@example.com", 
    name: "Alice Johnson",
    status: UserStatus.USER_STATUS_ACTIVE,
    createdAt: BigInt(Date.now() - 86400000), // 1 day ago
    updatedAt: BigInt(Date.now()),
  });

  const sampleProfile = new UserProfile({
    firstName: "Alice",
    lastName: "Johnson",
    bio: "Frontend developer passionate about type safety",
    avatarUrl: "https://example.com/avatars/alice.jpg",
    location: "San Francisco, CA",
    timezone: "America/Los_Angeles",
  });

  console.log("👤 Sample User (shared type):", {
    id: sampleUser.id,
    email: sampleUser.email,
    name: sampleUser.name,
    status: UserStatus[sampleUser.status],
  });
  console.log("");

  // 2. Demonstrate REST API calls with automatic HTTP mapping
  console.log("🔗 Connect-ES Client Examples (HTTP/REST via Google annotations):");
  console.log("==================================================================");
  console.log("");

  try {
    // Login request - automatically maps to: POST /api/v1/auth/login
    const loginRequest = new LoginRequest({
      email: "alice@example.com",
      password: "secure_password",
      rememberMe: true,
    });

    console.log("🔐 Login API Call:");
    console.log(`   HTTP: POST /api/v1/auth/login`);
    console.log(`   Body:`, {
      email: loginRequest.email,
      rememberMe: loginRequest.rememberMe,
      password: "[REDACTED]"
    });
    console.log(`   Note: Google API annotations provide HTTP mapping`);
    console.log("");

    // Get user request - automatically maps to: GET /api/v1/users/{user_id}  
    const getUserRequest = new GetUserRequest({
      userId: "user_12345",
      fields: ["id", "email", "name", "status"],
    });

    console.log("👤 Get User API Call:");
    console.log(`   HTTP: GET /api/v1/users/${getUserRequest.userId}`);
    console.log(`   Query: fields=${getUserRequest.fields.join(",")}`);
    console.log(`   Note: Path parameter from Google API annotations`);
    console.log("");

    // List users request - automatically maps to: GET /api/v1/users
    const listUsersRequest = new ListUsersRequest({
      pagination: new PaginationRequest({
        pageSize: 10,
        pageToken: "",
        orderBy: "created_at DESC",
      }),
      statusFilter: UserStatus.USER_STATUS_ACTIVE,
      searchQuery: "alice",
    });

    console.log("📋 List Users API Call:");
    console.log(`   HTTP: GET /api/v1/users`);
    console.log(`   Query:`, {
      page_size: listUsersRequest.pagination?.pageSize,
      status_filter: UserStatus[listUsersRequest.statusFilter],
      search_query: listUsersRequest.searchQuery,
      order_by: listUsersRequest.pagination?.orderBy,
    });
    console.log("");

    // Update profile request - automatically maps to: PUT /api/v1/users/{user_id}/profile
    const updateProfileRequest = new UpdateUserProfileRequest({
      userId: "user_12345",
      profile: sampleProfile,
    });

    console.log("✏️  Update Profile API Call:");
    console.log(`   HTTP: PUT /api/v1/users/${updateProfileRequest.userId}/profile`);
    console.log(`   Body:`, {
      firstName: updateProfileRequest.profile?.firstName,
      lastName: updateProfileRequest.profile?.lastName,
      bio: updateProfileRequest.profile?.bio?.substring(0, 50) + "...",
    });
    console.log("");

  } catch (error) {
    console.log("ℹ️  API calls are for demonstration only (no actual server)");
    console.log("");
  }

  // 3. Demonstrate type safety
  console.log("🔒 Type Safety Benefits:");
  console.log("=======================");
  console.log("• All API calls are fully type-checked at compile time");
  console.log("• Request/response types match backend Go definitions");
  console.log("• Google API annotations provide automatic HTTP mapping");
  console.log("• No manual REST client configuration needed");
  console.log("• Shared types ensure consistency between frontend/backend");
  console.log("");

  console.log("🚫 Security Benefits (Smart Exclusions):");
  console.log("========================================");
  console.log("• Frontend cannot access internal.v1.* services");
  console.log("• No InternalUserMetadata exposed to frontend");
  console.log("• No admin operations accessible from web clients");
  console.log("• Clear separation between public APIs and internal services");
  console.log("");
}

async function demonstratePerLanguageFilesBenefits() {
  console.log("🎯 Per-Language Files Feature Benefits");
  console.log("======================================");
  console.log("");
  console.log("📂 File Organization:");
  console.log("  Global files (both languages):");
  console.log("    • proto/common/v1/types.proto");
  console.log("    • proto/common/v1/status.proto");
  console.log("");
  console.log("  JavaScript additionalFiles:");
  console.log("    • proto/api/v1/user_api.proto        (public REST APIs)");
  console.log("    • proto/api/v1/auth_api.proto        (authentication)");
  console.log("    • proto/google/api/annotations.proto (HTTP mapping)");
  console.log("    • proto/google/api/http.proto        (REST definitions)");
  console.log("");
  console.log("  Go files (override global):");
  console.log("    • proto/common/v1/*.proto            (shared types)");
  console.log("    • proto/internal/v1/user_service.proto (backend gRPC)");
  console.log("    • proto/internal/v1/admin_service.proto (admin operations)");
  console.log("");
  console.log("✨ Results:");
  console.log("  • Faster builds (each language processes only relevant files)");
  console.log("  • Cleaner output (no unnecessary generated files)");
  console.log("  • Security boundaries (frontend can't access internal APIs)");
  console.log("  • No Go linting errors (Google annotations excluded from Go)");
  console.log("  • Clear separation of concerns");
  console.log("");
}

// Main execution
(async () => {
  try {
    await demonstrateTypeSafetyAndSmartGeneration();
    await demonstratePerLanguageFilesBenefits();
    
    console.log("🎉 Frontend Example Completed Successfully!");
    console.log("==========================================");
    console.log("");
    console.log("💡 Key Takeaways:");
    console.log("  1. per-language 'files' and 'additionalFiles' provide fine control");
    console.log("  2. Smart exclusions prevent problematic code generation");
    console.log("  3. Type safety maintained across frontend/backend boundaries");
    console.log("  4. Google API annotations work seamlessly with Connect-ES");
    console.log("  5. Security enforced at build time via file separation");
    console.log("");
    console.log("🔗 Next Steps:");
    console.log("  • Run backend: cd backend && go run main.go");
    console.log("  • Test generation: nix run (generates code for both languages)");
    console.log("  • Check exclusions: verify no internal/ files in frontend/");
    console.log("");
    
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1);
  }
})();