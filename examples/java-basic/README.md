# Java Basic Protobuf Example

This example demonstrates basic Java protobuf code generation using bufrnix with the `protocolbuffers/java` generator.

## Features

- Basic protobuf message definitions
- Java code generation with proper package structure
- Maven and Gradle build file generation
- Serialization and deserialization example

## Generated Code

The `protocolbuffers/java` generator creates:

- Java classes for each protobuf message
- Builder pattern for message construction
- Serialization methods (`toByteArray()`, `writeTo()`)
- Parsing methods (`parseFrom()`, `parseDelimitedFrom()`)
- Field accessors with proper naming conventions

## Quick Start

1. **Generate the protobuf code:**

   ```bash
   nix run .#generate
   ```

2. **Build with Gradle:**

   ```bash
   nix develop
   cd gen/java
   gradle build
   gradle run
   ```

3. **Or build with Maven:**
   ```bash
   nix develop
   cd gen/java
   mvn compile exec:java -Dexec.mainClass="com.example.Main"
   ```

## Proto Definition

The example uses a `Person` message with:

- Basic fields (id, name, email)
- Nested message (PhoneNumber)
- Enum (PhoneType)
- Repeated fields (phones)

## Generated Files

After running `nix run .#generate`, you'll find:

- `gen/java/com/example/protos/v1/` - Generated Java classes
- `gen/java/build.gradle` - Gradle build file
- `gen/java/pom.xml` - Maven build file

## Java Protobuf Features

This example showcases:

- Type-safe message builders
- Efficient binary serialization
- JSON serialization support (with additional dependencies)
- Reflection and descriptor access
- Thread-safe immutable messages
