# Java Protovalidate Example

This example demonstrates Java validation using bufrnix with the `bufbuild/validate-java` approach via the protovalidate-java runtime library.

## Features

- Runtime validation using CEL (Common Expression Language) expressions
- Comprehensive field validation rules (string length, patterns, numeric ranges, etc.)
- Message-level validation with custom logic
- Collection validation (min/max items, uniqueness)
- Type-safe validation with detailed error reporting

## Validation Rules Demonstrated

This example showcases various validation constraints:

### Field-Level Validations
- **Numeric ranges**: Age between 0-150, Score 0.0-100.0
- **String constraints**: Name length 1-50 characters
- **Pattern matching**: Email and phone number regex validation
- **Collection rules**: Phone numbers 1-3 items, unique values

### Message-Level Validations
- **Custom CEL expressions**: UserProfile requires either bio OR website
- **Cross-field validation**: Complex business logic validation

## Generated Code

The `bufbuild/validate-java` approach uses:
- Standard Java protobuf classes from `protocolbuffers/java`
- Runtime validation with the `protovalidate-java` library
- CEL expression evaluation for complex validations
- Detailed violation reporting with field paths

## Quick Start

1. **Generate the protobuf code:**
   ```bash
   nix run .#generate
   ```

2. **Build and run the validation example:**
   ```bash
   nix develop
   cd gen/java
   gradle build
   gradle run
   ```

## Validation Library

This example uses the `protovalidate-java` runtime library which provides:
- `Validator` class for validating protobuf messages
- `ValidationException` with detailed violation information
- Support for all standard constraint types
- CEL expression evaluation for custom rules

## Example Output

The validation example tests various scenarios:
- ✅ Valid user with all constraints satisfied
- ❌ Invalid users with specific constraint violations
- Detailed error messages showing which fields failed validation

## Dependencies

The generated build files include:
- `com.google.protobuf:protobuf-java` - Protocol Buffers runtime
- `build.buf:protovalidate` - Protovalidate Java runtime library

## Constraint Types

The example demonstrates these validation constraint types:
- **String**: `min_len`, `max_len`, `pattern`
- **Numeric**: `gt`, `gte`, `lt`, `lte`, `const`, `in`, `not_in`
- **Repeated**: `min_items`, `max_items`, `unique`
- **Custom**: CEL expressions for complex business logic

## Best Practices

1. **Fail fast**: Validate messages at service boundaries
2. **Clear messages**: Use descriptive constraint violation messages
3. **Performance**: Validator instances can be reused safely
4. **Error handling**: Always catch and handle `ValidationException`