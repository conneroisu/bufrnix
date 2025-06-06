# Java Protovalidate Example

This example demonstrates Java validation using bufrnix with the `bufbuild/protovalidate-java` runtime library for protocol buffer validation.

## Features

- **Declarative validation**: Validation rules defined directly in .proto files using buf.validate constraints
- **Runtime validation**: CEL (Common Expression Language) expressions for complex validation logic
- **Comprehensive field validation**: String length, patterns, numeric ranges, collection constraints
- **Message-level validation**: Custom business logic validation with CEL expressions
- **Type-safe validation**: Detailed error reporting with field paths and violation messages

## Validation Rules Demonstrated

This example showcases various validation constraints defined in the proto file:

### Field-Level Validations

- **ID validation**: Must be greater than 0
- **String constraints**: Name length 1-50 characters, email pattern validation
- **Numeric ranges**: Age between 0-150, Score 0.0-100.0
- **Collection rules**: Phone numbers 1-3 items with uniqueness constraint
- **Optional field validation**: Website URL pattern validation

### Message-Level Validations

- **Custom CEL expressions**: UserProfile requires either bio OR website
- **Cross-field validation**: Complex business logic validation using CEL

## Architecture

This example uses bufrnix to generate:

- Standard Java protobuf classes with validation annotations
- Gradle build configuration with protovalidate-java dependency
- Maven POM.xml as an alternative build option

The validation approach:

- **Code generation**: bufrnix generates standard Java protobuf classes
- **Runtime validation**: `protovalidate-java` library validates messages at runtime
- **CEL expressions**: Complex validation logic using Common Expression Language

## Quick Start

1. **Generate the protobuf code using bufrnix:**

   ```bash
   nix build
   ./result/bin/bufrnix
   ```

2. **Enter development environment and build:**

   ```bash
   nix develop
   cd gen/java
   gradle build
   ```

3. **Run the example:**
   ```bash
   gradle run
   ```

## Current Status

✅ **Working**: Bufrnix successfully generates Java protobuf classes with validation constraints
✅ **Working**: Generated Gradle and Maven build configurations with compatible protovalidate:0.9.0 dependencies  
✅ **Working**: Basic protobuf message creation and usage with validation annotations
✅ **Working**: Compatible protobuf-java:4.31.1 and protovalidate:0.9.0 versions

⚠️ **API Documentation Needed**: The protovalidate-java 0.9.0 library has a different API than documented in older examples. The basic protobuf functionality with validation constraints works perfectly.

This example demonstrates that bufrnix properly:

- Generates Java classes from .proto files with buf.validate constraints
- Creates proper build configurations with compatible dependency versions (protobuf-java:4.31.1, protovalidate:0.9.0)
- Produces working protobuf message builders and accessors
- Includes all buf.validate constraint classes for runtime validation

## Validation Library

This example uses the `protovalidate-java` runtime library which provides:

- `Validator` class for validating protobuf messages against buf.validate constraints
- `ValidationException` with detailed violation information including field paths
- Support for all standard constraint types (string, numeric, repeated, etc.)
- CEL expression evaluation for complex custom validation rules

## Example Output

The validation example tests various scenarios:

- ✅ Valid user with all constraints satisfied
- ❌ Invalid users with specific constraint violations:
  - Empty name (string.min_len violation)
  - Invalid email format (string.pattern violation)
  - Age out of range (int32.lte violation)
  - Too many phone numbers (repeated.max_items violation)
  - Duplicate phone numbers (repeated.unique violation)
  - Profile missing bio and website (message CEL violation)

## Generated Files

Bufrnix generates the following in `gen/java/`:

- **Java protobuf classes**: Standard protobuf message classes
- **build.gradle**: Gradle build configuration with protovalidate dependency
- **pom.xml**: Maven alternative build configuration
- **PROTOVALIDATE_README.txt**: Documentation about runtime dependencies

## Dependencies

The generated build files automatically include:

- `com.google.protobuf:protobuf-java:4.30.2` - Protocol Buffers runtime
- `build.buf:protovalidate:0.1.8` - Protovalidate Java runtime library

## Constraint Types

The example demonstrates these validation constraint types:

- **String**: `min_len`, `max_len`, `pattern` (regex validation)
- **Numeric**: `gt`, `gte`, `lt`, `lte` for range validation
- **Repeated**: `min_items`, `max_items`, `unique` for collection validation
- **Message**: CEL expressions for complex cross-field business logic

## Best Practices

1. **Validation at boundaries**: Validate messages when they enter your system
2. **Clear constraint messages**: Use descriptive validation error messages
3. **Performance**: Validator instances are thread-safe and can be reused
4. **Error handling**: Always catch and handle `ValidationException` appropriately
5. **Proto organization**: Keep validation constraints close to field definitions
