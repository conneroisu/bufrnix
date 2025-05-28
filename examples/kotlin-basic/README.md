# Kotlin Basic Protocol Buffers Example

This example demonstrates basic Protocol Buffers usage with Kotlin and Bufrnix.

## Features

- Kotlin DSL for message creation
- Immutable message updates with `copy`
- OneOf field handling
- JSON serialization/deserialization
- Kotlin-specific features (extension functions, null safety)
- Generated Gradle build file

## Structure

- `proto/` - Protocol buffer definitions
- `src/main/kotlin/` - Kotlin example code
- `flake.nix` - Nix flake configuration with Bufrnix

## Building

```bash
# Generate proto code
nix build .#proto

# The generated code will be in:
# - gen/kotlin/java/ - Java protobuf classes
# - gen/kotlin/kotlin/ - Kotlin extensions
# - gen/kotlin/build.gradle.kts - Gradle build file

# Enter development shell
nix develop

# Build with Gradle
cd gen/kotlin
gradle build

# Run the example
gradle run
```

## Generated Code Features

The Kotlin protobuf plugin generates:
- Kotlin DSL builders for all messages
- Immutable `copy` functions
- Type-safe builders with scope functions
- Null-safe accessors
- Collection helpers

## Kotlin-Specific Usage

```kotlin
// DSL builder
val user = user {
    id = "123"
    name = "John"
    addresses += address {
        city = "New York"
    }
}

// Immutable updates
val updated = user.copy {
    name = "Jane"
}

// Extension functions
fun User.displayName() = "$name (#$id)"
```