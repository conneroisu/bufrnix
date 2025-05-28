# JavaScript/TypeScript protovalidate-es Example

This example demonstrates how to use protovalidate-es with Bufrnix for runtime validation of Protocol Buffer messages in JavaScript/TypeScript.

## Overview

protovalidate-es provides runtime validation for Protocol Buffer messages using validation rules defined in `.proto` files. This example shows:

- Defining validation rules in proto files using `buf.validate` options
- Generating TypeScript code with validation support
- Using the `@bufbuild/protovalidate` runtime library to validate messages
- Handling validation errors

## Prerequisites

- Nix with flakes enabled
- Node.js (provided by the dev shell)

## Setup

1. Enter the development shell:

```bash
nix develop
```

2. Generate TypeScript code from proto files:

```bash
bufrnix_generate
```

3. Install dependencies:

```bash
npm install
```

## Running the Example

Build and run the validation examples:

```bash
npm test
```

Or run steps individually:

```bash
npm run build    # Compile TypeScript
npm run validate # Run validation examples
```

## Validation Rules

The example proto file (`proto/example/v1/user.proto`) demonstrates various validation rules:

- **String validation**: email format, length constraints, regex patterns
- **Numeric validation**: min/max values for integers
- **Enum validation**: ensuring only defined values are used
- **Collection validation**: min/max items in repeated fields
- **Complex validation**: nested message validation, required fields

## Key Features

1. **Type-safe validation**: All validation rules are defined in proto files and enforced at runtime
2. **Detailed error messages**: Validation failures provide field paths and descriptive messages
3. **CEL expressions**: Support for complex validation logic using Common Expression Language
4. **Zero code generation for validation**: Uses the same `protoc-gen-es` plugin with runtime validation

## Integration with Bufrnix

The `flake.nix` configuration enables protovalidate-es support:

```nix
languages.js = {
  enable = true;
  es.enable = true;
  protovalidate = {
    enable = true;
    target = "ts";
    generateValidationHelpers = true;
  };
};
```

This configuration:

- Enables ECMAScript module generation with `protoc-gen-es`
- Configures protovalidate support for TypeScript output
- Generates helper functions for validation

## Learn More

- [protovalidate Documentation](https://github.com/bufbuild/protovalidate)
- [protovalidate-es Documentation](https://github.com/bufbuild/protovalidate-es)
- [Buf Validate Rules Reference](https://buf.build/bufbuild/protovalidate/docs/main/validate/validate.proto)
