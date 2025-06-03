# Scala Basic Example

This example demonstrates how to use bufrnix to generate Scala code from Protocol Buffer definitions using ScalaPB.

## Structure

```
scala-basic/
├── flake.nix          # Nix flake configuration
├── README.md          # This file
├── proto/             # Protocol buffer definitions
│   └── example/
│       └── v1/
│           └── person.proto
└── src/
    └── main/
        └── scala/
            └── Main.scala  # Example Scala application
```

## Getting Started

### Using Nix (Recommended)

1. **Generate Protocol Buffer code:**
   ```bash
   nix run
   ```

2. **Run the example application:**
   ```bash
   nix run .#example
   ```

   This command will:
   - Generate the Scala code from proto files if needed
   - Compile the Scala project
   - Run the example application

### Development Workflow

1. **Enter the development shell:**
   ```bash
   nix develop
   ```

2. **Generate Protocol Buffer code:**
   ```bash
   nix run
   ```

3. **Build the Scala project:**
   ```bash
   sbt compile
   ```

4. **Run the example:**
   ```bash
   sbt run
   ```

## Configuration

The `flake.nix` file configures ScalaPB code generation:

```nix
scala = {
  enable = true;
  generateBuildFile = true;  # Generates build.sbt
  projectName = "ScalaProtoExample";
  organization = "com.example.protobuf";
};
```

## Features Demonstrated

- Basic Protocol Buffer to Scala code generation
- ScalaPB runtime usage
- Serialization and deserialization
- Working with generated case classes