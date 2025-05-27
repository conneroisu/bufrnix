# C nanopb Example

This example demonstrates using bufrnix to generate C code using nanopb, a lightweight Protocol Buffers implementation designed for embedded systems and microcontrollers.

## Overview

Nanopb is specifically designed for resource-constrained environments where:

- Memory is limited (kilobytes rather than megabytes)
- Dynamic memory allocation should be avoided
- Code size needs to be minimal
- No STL or RTTI support is available

## Building

To generate the nanopb C code from the proto files:

```bash
# Generate nanopb code
nix build

# Enter development shell with C toolchain
nix develop
```

## Generated Files

After running `nix build`, you'll find the generated C code in:

- `proto/gen/c/nanopb/sensor/v1/sensor.pb.h` - Header file with message definitions
- `proto/gen/c/nanopb/sensor/v1/sensor.pb.c` - Implementation file

## Key Features

### 1. Fixed-Size Arrays

The `sensor.options` file configures fixed-size arrays to avoid dynamic allocation:

```
sensor.v1.SensorReading.values max_count:10 fixed_count:true
```

### 2. String Size Limits

Strings have maximum sizes defined to enable static allocation:

```
sensor.v1.DeviceConfig.device_id max_size:32
```

### 3. Message Count Limits

Repeated message fields have maximum counts:

```
sensor.v1.TelemetryBatch.readings max_count:20
```

## Example Usage

```c
#include "proto/gen/c/nanopb/sensor/v1/sensor.pb.h"
#include <pb_encode.h>
#include <pb_decode.h>
#include <stdio.h>

// Encode a sensor reading
bool encode_sensor_reading(uint8_t *buffer, size_t buffer_size, size_t *message_length) {
    sensor_v1_SensorReading reading = sensor_v1_SensorReading_init_zero;

    // Fill in sensor data
    reading.timestamp = 1234567890;
    reading.temperature = 23.5f;
    reading.humidity = 65.2f;
    reading.pressure = 101325;
    reading.status = sensor_v1_SensorStatus_SENSOR_STATUS_OK;

    // Add some sensor values (fixed array)
    reading.values_count = 3;
    reading.values[0] = 1.23f;
    reading.values[1] = 4.56f;
    reading.values[2] = 7.89f;

    // Create output stream
    pb_ostream_t stream = pb_ostream_from_buffer(buffer, buffer_size);

    // Encode the message
    bool status = pb_encode(&stream, sensor_v1_SensorReading_fields, &reading);
    *message_length = stream.bytes_written;

    return status;
}

// Decode a sensor reading
bool decode_sensor_reading(const uint8_t *buffer, size_t message_length) {
    sensor_v1_SensorReading reading = sensor_v1_SensorReading_init_zero;

    // Create input stream
    pb_istream_t stream = pb_istream_from_buffer(buffer, message_length);

    // Decode the message
    bool status = pb_decode(&stream, sensor_v1_SensorReading_fields, &reading);

    if (status) {
        printf("Decoded reading:\n");
        printf("  Timestamp: %u\n", reading.timestamp);
        printf("  Temperature: %.2f°C\n", reading.temperature);
        printf("  Humidity: %.2f%%\n", reading.humidity);
        printf("  Pressure: %u Pa\n", reading.pressure);
        printf("  Values: ");
        for (size_t i = 0; i < reading.values_count; i++) {
            printf("%.2f ", reading.values[i]);
        }
        printf("\n");
    }

    return status;
}
```

## Memory Usage

Nanopb is designed for minimal memory usage:

- No dynamic memory allocation
- Fixed-size buffers for strings and arrays
- Minimal code size overhead
- Stack-based encoding/decoding

## Compiling

```bash
# In the development shell
gcc -o sensor_example main.c \
    proto/gen/c/nanopb/sensor/v1/sensor.pb.c \
    -I$(pkg-config --variable=includedir nanopb) \
    -L$(pkg-config --variable=libdir nanopb) \
    -lprotobuf-nanopb \
    -I.

./sensor_example
```

## Testing

A comprehensive test suite verifies nanopb functionality and memory constraints:

```bash
# Quick test: generate code and run tests
./test.sh

# Or manually:
nix build                # Generate nanopb code
nix develop             # Enter dev shell
make test               # Build and run tests
make run                # Run the example program
```

The test suite verifies:

- Static memory allocation (no malloc/free)
- Fixed-size arrays from options file
- String size constraints
- Message encoding/decoding
- Enum handling

## Use Cases

This nanopb example is ideal for:

- Microcontroller applications
- IoT devices
- Embedded Linux systems
- Real-time systems
- Battery-powered devices
- Systems with <100KB RAM
