#include "proto/gen/c/nanopb/sensor/v1/sensor.pb.h"
#include <pb_encode.h>
#include <pb_decode.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

// Test buffer size
#define TEST_BUFFER_SIZE 512

// Simple test to verify nanopb code generation and functionality
int main() {
    printf("Running nanopb tests...\n");
    
    // Test 1: Basic sensor reading encode/decode
    {
        printf("\nTest 1: Basic sensor reading\n");
        
        uint8_t buffer[TEST_BUFFER_SIZE];
        sensor_v1_SensorReading reading = sensor_v1_SensorReading_init_zero;
        
        // Fill sensor data
        reading.timestamp = 1234567890;
        reading.temperature = 23.5f;
        reading.humidity = 65.2f;
        reading.pressure = 101325;
        reading.status = sensor_v1_SensorStatus_SENSOR_STATUS_OK;
        
        // Add sensor values
        reading.values_count = 5;
        for (size_t i = 0; i < reading.values_count; i++) {
            reading.values[i] = i * 1.5f;
        }
        
        // Encode
        pb_ostream_t ostream = pb_ostream_from_buffer(buffer, sizeof(buffer));
        bool encode_status = pb_encode(&ostream, sensor_v1_SensorReading_fields, &reading);
        assert(encode_status);
        size_t message_length = ostream.bytes_written;
        printf("  ✓ Encoded to %zu bytes\n", message_length);
        
        // Decode
        sensor_v1_SensorReading decoded = sensor_v1_SensorReading_init_zero;
        pb_istream_t istream = pb_istream_from_buffer(buffer, message_length);
        bool decode_status = pb_decode(&istream, sensor_v1_SensorReading_fields, &decoded);
        assert(decode_status);
        
        // Verify
        assert(decoded.timestamp == 1234567890);
        assert(decoded.temperature == 23.5f);
        assert(decoded.humidity == 65.2f);
        assert(decoded.pressure == 101325);
        assert(decoded.status == sensor_v1_SensorStatus_SENSOR_STATUS_OK);
        assert(decoded.values_count == 5);
        printf("  ✓ Decoded successfully\n");
        printf("  ✓ Temperature: %.2f°C\n", decoded.temperature);
        printf("  ✓ Values count: %zu\n", decoded.values_count);
    }
    
    // Test 2: Device configuration with strings
    {
        printf("\nTest 2: Device configuration\n");
        
        uint8_t buffer[TEST_BUFFER_SIZE];
        sensor_v1_DeviceConfig config = sensor_v1_DeviceConfig_init_zero;
        
        // Fill config - note the string size limits from .options file
        strncpy(config.device_id, "SENSOR-TEST-001", sizeof(config.device_id) - 1);
        config.sample_rate = 100;
        config.enable_logging = true;
        
        // Set calibration data
        config.has_temperature_cal = true;
        config.temperature_cal.offset = -0.5f;
        config.temperature_cal.scale = 1.02f;
        
        config.has_humidity_cal = true;
        config.humidity_cal.offset = 2.0f;
        config.humidity_cal.scale = 0.98f;
        
        // Encode
        pb_ostream_t ostream = pb_ostream_from_buffer(buffer, sizeof(buffer));
        bool encode_status = pb_encode(&ostream, sensor_v1_DeviceConfig_fields, &config);
        assert(encode_status);
        size_t message_length = ostream.bytes_written;
        printf("  ✓ Encoded config to %zu bytes\n", message_length);
        
        // Decode
        sensor_v1_DeviceConfig decoded = sensor_v1_DeviceConfig_init_zero;
        pb_istream_t istream = pb_istream_from_buffer(buffer, message_length);
        bool decode_status = pb_decode(&istream, sensor_v1_DeviceConfig_fields, &decoded);
        assert(decode_status);
        
        // Verify
        assert(strcmp(decoded.device_id, "SENSOR-TEST-001") == 0);
        assert(decoded.sample_rate == 100);
        assert(decoded.enable_logging == true);
        assert(decoded.has_temperature_cal);
        assert(decoded.temperature_cal.offset == -0.5f);
        printf("  ✓ Device ID: %s\n", decoded.device_id);
        printf("  ✓ Sample rate: %u Hz\n", decoded.sample_rate);
    }
    
    // Test 3: Telemetry batch with repeated messages
    {
        printf("\nTest 3: Telemetry batch\n");
        
        uint8_t buffer[TEST_BUFFER_SIZE];
        sensor_v1_TelemetryBatch batch = sensor_v1_TelemetryBatch_init_zero;
        
        // Set device ID
        strncpy(batch.device_id, "BATCH-TEST", sizeof(batch.device_id) - 1);
        batch.batch_number = 42;
        
        // Add multiple readings
        batch.readings_count = 3;
        for (size_t i = 0; i < batch.readings_count; i++) {
            batch.readings[i].timestamp = 1000000000 + i * 60;
            batch.readings[i].temperature = 20.0f + i * 0.5f;
            batch.readings[i].humidity = 60.0f + i * 1.0f;
            batch.readings[i].pressure = 101300 + i * 10;
            batch.readings[i].status = sensor_v1_SensorStatus_SENSOR_STATUS_OK;
            batch.readings[i].values_count = 2;
            batch.readings[i].values[0] = i * 1.0f;
            batch.readings[i].values[1] = i * 2.0f;
        }
        
        // Encode
        pb_ostream_t ostream = pb_ostream_from_buffer(buffer, sizeof(buffer));
        bool encode_status = pb_encode(&ostream, sensor_v1_TelemetryBatch_fields, &batch);
        assert(encode_status);
        size_t message_length = ostream.bytes_written;
        printf("  ✓ Encoded batch to %zu bytes\n", message_length);
        
        // Decode
        sensor_v1_TelemetryBatch decoded = sensor_v1_TelemetryBatch_init_zero;
        pb_istream_t istream = pb_istream_from_buffer(buffer, message_length);
        bool decode_status = pb_decode(&istream, sensor_v1_TelemetryBatch_fields, &decoded);
        assert(decode_status);
        
        // Verify
        assert(strcmp(decoded.device_id, "BATCH-TEST") == 0);
        assert(decoded.batch_number == 42);
        assert(decoded.readings_count == 3);
        printf("  ✓ Batch contains %zu readings\n", decoded.readings_count);
        
        for (size_t i = 0; i < decoded.readings_count; i++) {
            printf("  ✓ Reading[%zu]: temp=%.1f°C, humidity=%.1f%%\n",
                   i, decoded.readings[i].temperature, decoded.readings[i].humidity);
        }
    }
    
    // Test 4: Enum values
    {
        printf("\nTest 4: Sensor status enum\n");
        
        uint8_t buffer[TEST_BUFFER_SIZE];
        sensor_v1_SensorStatus statuses[] = {
            sensor_v1_SensorStatus_SENSOR_STATUS_UNKNOWN,
            sensor_v1_SensorStatus_SENSOR_STATUS_OK,
            sensor_v1_SensorStatus_SENSOR_STATUS_WARNING,
            sensor_v1_SensorStatus_SENSOR_STATUS_ERROR
        };
        const char *status_names[] = {"UNKNOWN", "OK", "WARNING", "ERROR"};
        
        for (int i = 0; i < 4; i++) {
            sensor_v1_SensorReading reading = sensor_v1_SensorReading_init_zero;
            reading.timestamp = 1000;
            reading.temperature = 25.0f;
            reading.status = statuses[i];
            
            pb_ostream_t ostream = pb_ostream_from_buffer(buffer, sizeof(buffer));
            bool encode_status = pb_encode(&ostream, sensor_v1_SensorReading_fields, &reading);
            assert(encode_status);
            
            sensor_v1_SensorReading decoded = sensor_v1_SensorReading_init_zero;
            pb_istream_t istream = pb_istream_from_buffer(buffer, ostream.bytes_written);
            bool decode_status = pb_decode(&istream, sensor_v1_SensorReading_fields, &decoded);
            assert(decode_status);
            assert(decoded.status == statuses[i]);
            
            printf("  ✓ Status %s (%d)\n", status_names[i], decoded.status);
        }
    }
    
    // Test 5: Memory usage demonstration
    {
        printf("\nTest 5: Memory usage\n");
        printf("  ✓ SensorReading size: %zu bytes\n", sizeof(sensor_v1_SensorReading));
        printf("  ✓ DeviceConfig size: %zu bytes\n", sizeof(sensor_v1_DeviceConfig));
        printf("  ✓ TelemetryBatch size: %zu bytes\n", sizeof(sensor_v1_TelemetryBatch));
        printf("  ✓ All structures use static allocation\n");
    }
    
    printf("\n✅ All nanopb tests passed!\n");
    return 0;
}