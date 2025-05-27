# C protobuf-c Example

This example demonstrates using bufrnix to generate C code using the protobuf-c implementation.

## Overview

protobuf-c is a C implementation of the Protocol Buffers data format. It provides both a runtime library and a code generator that produces C code from `.proto` files.

## Building

To generate the C code from the proto files:

```bash
# Generate protobuf-c code
nix build

# Enter development shell with C toolchain
nix develop
```

## Generated Files

After running `nix build`, you'll find the generated C code in:

- `proto/gen/c/protobuf-c/example/v1/example.pb-c.h` - Header file with message definitions
- `proto/gen/c/protobuf-c/example/v1/example.pb-c.c` - Implementation file

## Using the Generated Code

Here's a simple example of using the generated protobuf-c code:

```c
#include "proto/gen/c/protobuf-c/example/v1/example.pb-c.h"
#include <stdio.h>
#include <stdlib.h>

int main() {
    // Create and initialize an Example message
    Example__V1__Example example = EXAMPLE__V1__EXAMPLE__INIT;
    example.id = "test-id";
    example.name = "Test Example";
    example.value = 42;
    example.type = EXAMPLE__V1__EXAMPLE_TYPE__BASIC;

    // Serialize the message
    size_t size = example__v1__example__get_packed_size(&example);
    uint8_t *buffer = malloc(size);
    example__v1__example__pack(&example, buffer);

    printf("Serialized message size: %zu bytes\n", size);

    // Deserialize the message
    Example__V1__Example *unpacked =
        example__v1__example__unpack(NULL, size, buffer);

    if (unpacked) {
        printf("Unpacked: id=%s, name=%s, value=%d\n",
               unpacked->id, unpacked->name, unpacked->value);
        example__v1__example__free_unpacked(unpacked, NULL);
    }

    free(buffer);
    return 0;
}
```

## Compiling the Example

```bash
# In the development shell
gcc -o example main.c proto/gen/c/protobuf-c/example/v1/example.pb-c.c \
    -lprotobuf-c -I.

./example
```

## Testing

A comprehensive test suite is included. To run all tests:

```bash
# Quick test: generate code and run tests
./test.sh

# Or manually:
nix build                # Generate protobuf code
nix develop             # Enter dev shell
make test               # Build and run tests
make run                # Run the example program
```

## Features Demonstrated

- Basic message serialization/deserialization
- Enum types
- Repeated fields
- Nested messages
- Map fields
- Service definitions (basic stubs)

## protobuf-c Specific Features

- Lightweight C implementation
- No C++ dependencies
- Suitable for embedded systems
- Support for extensions
- Basic service/RPC support
