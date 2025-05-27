#include "proto/gen/c/nanopb/sensor/v1/sensor.pb.h"
#include <pb_encode.h>
#include <pb_decode.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

// Buffer size for encoding/decoding
#define BUFFER_SIZE 256

// Helper function to print sensor reading
void print_sensor_reading(const sensor_v1_SensorReading *reading) {
    printf("SensorReading {\n");
    printf("  timestamp: %u\n", reading->timestamp);
    printf("  temperature: %.2f°C\n", reading->temperature);
    printf("  humidity: %.2f%%\n", reading->humidity);
    printf("  pressure: %u Pa\n", reading->pressure);
    printf("  status: ");
    switch (reading->status) {
        case sensor_v1_SensorStatus_SENSOR_STATUS_OK:
            printf("OK\n");
            break;
        case sensor_v1_SensorStatus_SENSOR_STATUS_WARNING:
            printf("WARNING\n");
            break;
        case sensor_v1_SensorStatus_SENSOR_STATUS_ERROR:
            printf("ERROR\n");
            break;
        default:
            printf("UNKNOWN\n");
    }
    printf("  values[%zu]: ", reading->values_count);
    for (size_t i = 0; i < reading->values_count; i++) {
        printf("%.2f ", reading->values[i]);
    }
    printf("\n}\n");
}

// Encode a sensor reading
bool encode_sensor_reading(uint8_t *buffer, size_t buffer_size, size_t *message_length) {
    sensor_v1_SensorReading reading = sensor_v1_SensorReading_init_zero;
    
    // Fill in sensor data
    reading.timestamp = (uint32_t)time(NULL);
    reading.temperature = 23.5f;
    reading.humidity = 65.2f;
    reading.pressure = 101325;
    reading.status = sensor_v1_SensorStatus_SENSOR_STATUS_OK;
    
    // Add sensor values (demonstrating fixed array usage)
    reading.values_count = 5;
    for (size_t i = 0; i < reading.values_count; i++) {
        reading.values[i] = 10.0f + i * 2.5f;
    }
    
    printf("Encoding sensor reading:\n");
    print_sensor_reading(&reading);
    
    // Create output stream
    pb_ostream_t stream = pb_ostream_from_buffer(buffer, buffer_size);
    
    // Encode the message
    bool status = pb_encode(&stream, sensor_v1_SensorReading_fields, &reading);
    if (status) {
        *message_length = stream.bytes_written;
        printf("\nEncoded to %zu bytes\n", *message_length);
    } else {
        printf("Encoding failed: %s\n", PB_GET_ERROR(&stream));
    }
    
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
        printf("\nDecoded sensor reading:\n");
        print_sensor_reading(&reading);
    } else {
        printf("Decoding failed: %s\n", PB_GET_ERROR(&stream));
    }
    
    return status;
}

// Demonstrate device configuration
void demonstrate_device_config() {
    uint8_t buffer[BUFFER_SIZE];
    size_t message_length;
    
    printf("\n=== Device Configuration Example ===\n");
    
    // Create and encode device config
    sensor_v1_DeviceConfig config = sensor_v1_DeviceConfig_init_zero;
    strncpy(config.device_id, "SENSOR-001", sizeof(config.device_id) - 1);
    config.sample_rate = 100; // 100 Hz
    config.enable_logging = true;
    
    // Set calibration data
    config.has_temperature_cal = true;
    config.temperature_cal.offset = -0.5f;
    config.temperature_cal.scale = 1.02f;
    
    config.has_humidity_cal = true;
    config.humidity_cal.offset = 2.0f;
    config.humidity_cal.scale = 0.98f;
    
    // Encode
    pb_ostream_t stream = pb_ostream_from_buffer(buffer, sizeof(buffer));
    if (pb_encode(&stream, sensor_v1_DeviceConfig_fields, &config)) {
        message_length = stream.bytes_written;
        printf("Device config encoded to %zu bytes\n", message_length);
        
        // Decode to verify
        sensor_v1_DeviceConfig decoded_config = sensor_v1_DeviceConfig_init_zero;
        pb_istream_t istream = pb_istream_from_buffer(buffer, message_length);
        if (pb_decode(&istream, sensor_v1_DeviceConfig_fields, &decoded_config)) {
            printf("Decoded config:\n");
            printf("  Device ID: %s\n", decoded_config.device_id);
            printf("  Sample rate: %u Hz\n", decoded_config.sample_rate);
            printf("  Logging: %s\n", decoded_config.enable_logging ? "enabled" : "disabled");
            if (decoded_config.has_temperature_cal) {
                printf("  Temperature cal: offset=%.2f, scale=%.2f\n",
                       decoded_config.temperature_cal.offset,
                       decoded_config.temperature_cal.scale);
            }
        }
    }
}

// Demonstrate telemetry batch
void demonstrate_telemetry_batch() {
    uint8_t buffer[BUFFER_SIZE];
    
    printf("\n=== Telemetry Batch Example ===\n");
    
    // Create telemetry batch
    sensor_v1_TelemetryBatch batch = sensor_v1_TelemetryBatch_init_zero;
    strncpy(batch.device_id, "SENSOR-001", sizeof(batch.device_id) - 1);
    batch.batch_number = 42;
    
    // Add multiple readings
    batch.readings_count = 3;
    for (size_t i = 0; i < batch.readings_count; i++) {
        batch.readings[i].timestamp = (uint32_t)(time(NULL) + i * 10);
        batch.readings[i].temperature = 20.0f + i * 0.5f;
        batch.readings[i].humidity = 60.0f + i * 2.0f;
        batch.readings[i].pressure = 101300 + i * 10;
        batch.readings[i].status = sensor_v1_SensorStatus_SENSOR_STATUS_OK;
        batch.readings[i].values_count = 2;
        batch.readings[i].values[0] = i * 1.1f;
        batch.readings[i].values[1] = i * 2.2f;
    }
    
    // Calculate message size
    size_t size = 0;
    if (pb_get_encoded_size(&size, sensor_v1_TelemetryBatch_fields, &batch)) {
        printf("Telemetry batch will require %zu bytes\n", size);
        printf("Batch contains %zu readings\n", batch.readings_count);
    }
}

int main() {
    printf("nanopb Example - Embedded Protocol Buffers\n");
    printf("==========================================\n\n");
    
    uint8_t buffer[BUFFER_SIZE];
    size_t message_length;
    
    // Test sensor reading encode/decode
    printf("=== Sensor Reading Example ===\n");
    if (encode_sensor_reading(buffer, sizeof(buffer), &message_length)) {
        if (!decode_sensor_reading(buffer, message_length)) {
            fprintf(stderr, "Failed to decode sensor reading\n");
            return 1;
        }
    } else {
        fprintf(stderr, "Failed to encode sensor reading\n");
        return 1;
    }
    
    // Demonstrate other message types
    demonstrate_device_config();
    demonstrate_telemetry_batch();
    
    printf("\n=== Memory Usage ===\n");
    printf("SensorReading size: %zu bytes\n", sizeof(sensor_v1_SensorReading));
    printf("DeviceConfig size: %zu bytes\n", sizeof(sensor_v1_DeviceConfig));
    printf("TelemetryBatch size: %zu bytes\n", sizeof(sensor_v1_TelemetryBatch));
    
    printf("\nExample completed successfully!\n");
    printf("\nNote: This example uses static allocation throughout.\n");
    printf("No malloc/free calls were made during execution.\n");
    
    return 0;
}