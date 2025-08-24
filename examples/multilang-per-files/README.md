# Multi-Language Per-Files Example

This example demonstrates **per-language file configuration** in Bufrnix, allowing you to control exactly which proto files each language processes. This enables smart exclusions and separation of concerns between frontend and backend code generation.

## 🎯 Key Features Demonstrated

- **Smart File Separation**: Different proto files for different languages
- **Google Annotations Exclusion**: Go backend doesn't generate Google API annotations (prevents linting errors)
- **Security Boundaries**: Frontend can't access internal backend services
- **Type Safety**: Shared types ensure consistency across languages
- **Performance**: Each language processes only relevant files

## 📁 Project Structure

```
multilang-per-files/
├── flake.nix                      # Bufrnix configuration with per-language files
├── proto/
│   ├── common/v1/                 # Shared types (both Go & JS)
│   │   ├── types.proto            # User, UserProfile, UserStatus
│   │   └── status.proto           # ResponseStatus, ErrorDetails
│   ├── api/v1/                    # Public REST APIs (JS only)
│   │   ├── user_api.proto         # Public user endpoints
│   │   └── auth_api.proto         # Authentication endpoints  
│   ├── internal/v1/               # Internal gRPC services (Go only)
│   │   ├── user_service.proto     # Backend user operations
│   │   └── admin_service.proto    # Admin-only operations
│   └── google/api/                # Google API annotations (JS only)
│       ├── annotations.proto      # HTTP annotations
│       └── http.proto             # HTTP definitions
├── backend/                       # Go application
│   ├── go.mod
│   ├── main.go                    # gRPC server demo
│   └── generated/go/              # Generated Go code
└── frontend/                      # TypeScript web app
    ├── package.json
    ├── tsconfig.json
    ├── src/index.ts               # Connect-ES client demo
    └── src/proto/generated/       # Generated TypeScript code
```

## 🔧 Configuration Highlights

The `flake.nix` demonstrates the new per-language files feature:

```nix
config = {
  # Global files (shared by all languages)
  protoc.files = [
    "./proto/common/v1/types.proto"
    "./proto/common/v1/status.proto"
  ];

  languages = {
    # Go Backend - Override global files
    go = {
      files = [
        # Shared types
        "./proto/common/v1/types.proto"
        "./proto/common/v1/status.proto"
        # Backend-only services  
        "./proto/internal/v1/user_service.proto"
        "./proto/internal/v1/admin_service.proto"
        # NOTE: No Google API annotations (prevents linting errors)
      ];
      grpc.enable = true;
    };
    
    # JavaScript Frontend - Extend global files
    js = {
      additionalFiles = [
        # Public APIs
        "./proto/api/v1/user_api.proto"
        "./proto/api/v1/auth_api.proto"
        # Google annotations (needed for REST)
        "./proto/google/api/annotations.proto"
        "./proto/google/api/http.proto"
        # NOTE: No internal services (security boundary)
      ];
      es.enable = true;
    };
  };
}
```

## 🚀 Quick Start

### 1. Generate Code

```bash
nix run
```

This generates:
- **Go**: `backend/generated/go/` - Internal services + shared types
- **TypeScript**: `frontend/src/proto/generated/` - Public APIs + shared types + Google annotations

### 2. Test Backend (Go)

```bash
cd backend
go run main.go
```

Shows:
- ✅ Generated: `common/v1`, `internal/v1` packages
- ❌ Not generated: `api/v1`, `google/api` (correctly excluded)
- Demonstrates internal gRPC services and admin operations

### 3. Test Frontend (TypeScript)

```bash
cd frontend
npm install
npm run dev
```

Shows:
- ✅ Generated: `common/v1`, `api/v1`, `google/api` packages
- ❌ Not generated: `internal/v1` (correctly excluded)  
- Demonstrates Connect-ES clients with Google annotations

## 🎯 Benefits Demonstrated

### 1. Smart Exclusions Prevent Problems

**Problem Solved**: Go + Google API annotations = linting errors
**Solution**: Go `files` excludes Google annotations, JS `additionalFiles` includes them

**Before (all languages get all files)**:
```
❌ Go generates google/api/annotations.pb.go → linting errors
❌ JS gets internal services → security risk
❌ Slower builds → unnecessary processing
```

**After (per-language file control)**:
```
✅ Go: Only internal services + shared types
✅ JS: Only public APIs + shared types + Google annotations
✅ Faster builds, cleaner output, better security
```

### 2. Clear Separation of Concerns

| Language | Files Processed | Generated Packages | Purpose |
|----------|----------------|-------------------|---------|
| **Go** | `common/*` + `internal/*` | Backend services | gRPC servers, admin ops |
| **JS** | `common/*` + `api/*` + `google/*` | REST clients | HTTP APIs, authentication |

### 3. Type Safety Maintained

Shared `common/v1` types ensure consistency:
```typescript
// Frontend
const user: User = new User({ id: "123", name: "Alice" });

// Backend (Go)
user := &commonv1.User{ Id: "123", Name: "Alice" }
```

## 📋 Testing Smart Exclusions

Verify correct generation with these checks:

```bash
# Should exist - Go backend files
ls backend/generated/go/common/v1/
ls backend/generated/go/internal/v1/

# Should NOT exist - Go correctly excludes these
ls backend/generated/go/api/v1/ 2>/dev/null || echo "✅ Correctly excluded"
ls backend/generated/go/google/api/ 2>/dev/null || echo "✅ Correctly excluded"

# Should exist - JS frontend files  
ls frontend/src/proto/generated/common/v1/
ls frontend/src/proto/generated/api/v1/
ls frontend/src/proto/generated/google/api/

# Should NOT exist - JS correctly excludes these
ls frontend/src/proto/generated/internal/v1/ 2>/dev/null || echo "✅ Correctly excluded"
```

## 🛠 Configuration Options

### `files` (override)
Completely replaces global `protoc.files` for a specific language:

```nix
languages.go.files = [
  "./proto/backend-specific.proto"
  "./proto/shared.proto"  
];
# Result: Go only processes these files, ignores protoc.files
```

### `additionalFiles` (extend)
Adds files to global `protoc.files` for a specific language:

```nix
languages.js.additionalFiles = [
  "./proto/frontend-specific.proto"
];
# Result: JS processes protoc.files + additionalFiles
```

### Use Cases

| Scenario | Use | Example |
|----------|-----|---------|
| **Complete override** | `files` | Go backend needs only internal services |
| **Add specific files** | `additionalFiles` | JS needs Google annotations |
| **Mixed architecture** | Both | Some languages override, others extend |

## 🔐 Security Benefits

Per-language files create natural security boundaries:

1. **Frontend Isolation**: Can't access internal admin operations
2. **Backend Focus**: Only processes relevant backend services  
3. **Compile-Time Enforcement**: Security boundaries enforced at build time
4. **Principle of Least Privilege**: Each language gets only necessary files

## ⚡ Performance Benefits

- **Faster Builds**: Each language processes fewer files
- **Smaller Output**: No unnecessary generated code
- **Reduced Complexity**: Cleaner proto dependency graphs
- **Better Caching**: More granular build artifacts

## 🎓 Learning Outcomes

After running this example, you'll understand:

1. How to use `files` and `additionalFiles` for per-language control
2. Why Go + Google annotations cause linting errors (and how to fix it)
3. How to enforce security boundaries at build time
4. Best practices for multi-language protobuf projects
5. Connect-ES integration with Google API annotations

## 🔗 Related Examples

- `js-annotations` - Basic JavaScript with Google annotations
- `go-advanced` - Advanced Go with multiple plugins
- `multilang` - Basic multi-language generation (no file separation)

This example shows the **advanced** multi-language pattern with smart file separation and security boundaries.