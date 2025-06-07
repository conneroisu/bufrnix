# Multi-Language Protobuf Example

This example demonstrates how to use Bufrnix to generate protobuf code for multiple programming languages from a single `.proto` file. It showcases the power and flexibility of Bufrnix in supporting polyglot development environments.

## Overview

The example uses a comprehensive `user.proto` file that defines:

- **User Message**: Complete user data structure with preferences, timestamps, and status
- **UserService gRPC Service**: Full CRUD operations for user management
- **Enumerations**: User status and theme preferences
- **Nested Messages**: User preferences structure

## Supported Languages

This example generates code for the following languages:

| Language                  | Features                           | Output Directory    |
| ------------------------- | ---------------------------------- | ------------------- |
| **Go**                    | Basic protobuf + gRPC + JSON tags  | `proto/gen/go/`     |
| **Python**                | Basic protobuf + gRPC + mypy stubs | `proto/gen/python/` |
| **JavaScript/TypeScript** | ES modules support                 | `proto/gen/js/`     |
| **Java**                  | Basic protobuf + gRPC              | `proto/gen/java/`   |
| **C++**                   | Basic protobuf + gRPC              | `proto/gen/cpp/`    |
| **Rust**                  | Tonic gRPC support                 | `proto/gen/rust/`   |

## Getting Started

### Prerequisites

- Nix with flakes enabled
- Git

### Generate Code for All Languages

```bash
# Clone the repository and navigate to this example
cd examples/multilang

# Generate protobuf code for all languages
nix build

# Check generated code
ls proto/gen/
```

### Language-Specific Development

Each language has its own development shell with appropriate tools and dependencies:

#### Go Development

```bash
nix develop .#go
cd proto/gen/go
# Go modules and code will be available here
```

#### Python Development

```bash
nix develop .#python
cd proto/gen/python
# Python modules with type stubs will be available here
```

#### JavaScript/TypeScript Development

```bash
nix develop .#js
cd proto/gen/js
# ES modules will be available here
```

#### Java Development

```bash
nix develop .#java
cd proto/gen/java
# Java classes and Gradle build files will be available here
```

#### C++ Development

```bash
nix develop .#cpp
cd proto/gen/cpp
# C++ headers and source files will be available here
```

#### Rust Development

```bash
nix develop .#rust
cd proto/gen/rust
# Rust modules with Tonic gRPC support will be available here
```

## Example Usage

### Go

```go
package main

import (
    "context"
    userv1 "path/to/proto/gen/go/example/v1"
    "google.golang.org/grpc"
)

func main() {
    // Create a new user
    user := &userv1.User{
        Id:    1,
        Email: "user@example.com",
        Name:  "John Doe",
        Age:   30,
        Preferences: &userv1.UserPreferences{
            Language:           "en",
            Timezone:          "UTC",
            EmailNotifications: true,
            Theme:             userv1.Theme_THEME_DARK,
        },
        Status: userv1.UserStatus_USER_STATUS_ACTIVE,
    }
    // Use the user...
}
```

### Python

```python
from proto.gen.python.example.v1 import user_pb2

# Create a new user
user = user_pb2.User(
    id=1,
    email="user@example.com",
    name="John Doe",
    age=30,
    preferences=user_pb2.UserPreferences(
        language="en",
        timezone="UTC",
        email_notifications=True,
        theme=user_pb2.Theme.THEME_DARK
    ),
    status=user_pb2.UserStatus.USER_STATUS_ACTIVE
)
```

### JavaScript/TypeScript

```javascript
import {
  User,
  UserPreferences,
  Theme,
  UserStatus,
} from "./proto/gen/js/example/v1/user_pb.js";

// Create a new user
const user = new User({
  id: 1,
  email: "user@example.com",
  name: "John Doe",
  age: 30,
  preferences: new UserPreferences({
    language: "en",
    timezone: "UTC",
    emailNotifications: true,
    theme: Theme.THEME_DARK,
  }),
  status: UserStatus.USER_STATUS_ACTIVE,
});
```

## Configuration Details

The `flake.nix` configuration demonstrates several important Bufrnix features:

### Multi-Language Support

```nix
languages = {
  go = {
    enable = true;
    grpc.enable = true;
    json.enable = true;
  };
  python = {
    enable = true;
    grpc.enable = true;
    mypy.enable = true;
  };
  # ... other languages
};
```

### Language-Specific Development Shells

Each language gets its own development environment with appropriate tools and dependencies, accessible via `nix develop .#<language>`.

### Flexible Output Paths

Each language can have its own output directory structure, making it easy to integrate with existing projects.

## Benefits of This Approach

1. **Consistency**: Single source of truth for data structures across all languages
2. **Type Safety**: Generated code provides compile-time type checking
3. **gRPC Support**: Automatic service client/server generation for supported languages
4. **Developer Experience**: Language-specific development shells with proper tooling
5. **Documentation**: Automatic documentation generation from proto comments
6. **Polyglot Teams**: Different teams can work in their preferred language while maintaining compatibility

## Integration with Existing Projects

To integrate this approach into your existing project:

1. Copy the `flake.nix` structure
2. Modify the `languages` section to include only the languages you need
3. Adjust output paths to match your project structure
4. Update the proto files and paths as needed

## Next Steps

- Explore the [multilang-multi-project](../multilang-multi-project/) example for more complex scenarios
- Check out language-specific examples for deep dives into individual language features
- Read the [Bufrnix documentation](../../doc/) for advanced configuration options
