#include "proto/gen/c/protobuf-c/example/v1/example.pb-c.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

// Simple test to verify protobuf-c code generation and functionality
int main() {
    printf("Running protobuf-c tests...\n");
    
    // Test 1: Basic message creation and serialization
    {
        printf("\nTest 1: Basic message serialization/deserialization\n");
        
        Example__V1__Example example = EXAMPLE__V1__EXAMPLE__INIT;
        example.id = "test-001";
        example.name = "Test Example";
        example.value = 42;
        example.type = EXAMPLE__V1__EXAMPLE_TYPE__BASIC;
        
        // Serialize
        size_t size = example__v1__example__get_packed_size(&example);
        uint8_t *buffer = malloc(size);
        assert(buffer != NULL);
        
        size_t packed_size = example__v1__example__pack(&example, buffer);
        assert(packed_size == size);
        printf("  ✓ Serialized to %zu bytes\n", size);
        
        // Deserialize
        Example__V1__Example *unpacked = 
            example__v1__example__unpack(NULL, size, buffer);
        assert(unpacked != NULL);
        assert(strcmp(unpacked->id, "test-001") == 0);
        assert(strcmp(unpacked->name, "Test Example") == 0);
        assert(unpacked->value == 42);
        assert(unpacked->type == EXAMPLE__V1__EXAMPLE_TYPE__BASIC);
        printf("  ✓ Deserialized successfully\n");
        
        example__v1__example__free_unpacked(unpacked, NULL);
        free(buffer);
    }
    
    // Test 2: Nested message with map
    {
        printf("\nTest 2: Nested message with metadata map\n");
        
        Example__V1__Example inner = EXAMPLE__V1__EXAMPLE__INIT;
        inner.id = "inner-001";
        inner.name = "Inner Example";
        inner.value = 100;
        
        Example__V1__NestedExample nested = EXAMPLE__V1__NESTED_EXAMPLE__INIT;
        nested.example = &inner;
        
        // Create metadata entries
        Example__V1__NestedExample__MetadataEntry entry1 = 
            EXAMPLE__V1__NESTED_EXAMPLE__METADATA_ENTRY__INIT;
        entry1.key = "version";
        entry1.value = "1.0";
        
        Example__V1__NestedExample__MetadataEntry entry2 = 
            EXAMPLE__V1__NESTED_EXAMPLE__METADATA_ENTRY__INIT;
        entry2.key = "author";
        entry2.value = "bufrnix";
        
        Example__V1__NestedExample__MetadataEntry *entries[] = {&entry1, &entry2};
        nested.metadata = entries;
        nested.n_metadata = 2;
        
        // Add binary data
        uint8_t data[] = {0x01, 0x02, 0x03, 0x04, 0x05};
        nested.data.data = data;
        nested.data.len = sizeof(data);
        
        // Serialize
        size_t size = example__v1__nested_example__get_packed_size(&nested);
        uint8_t *buffer = malloc(size);
        assert(buffer != NULL);
        
        size_t packed_size = example__v1__nested_example__pack(&nested, buffer);
        assert(packed_size == size);
        printf("  ✓ Nested message serialized to %zu bytes\n", size);
        
        // Deserialize
        Example__V1__NestedExample *unpacked = 
            example__v1__nested_example__unpack(NULL, size, buffer);
        assert(unpacked != NULL);
        assert(unpacked->example != NULL);
        assert(strcmp(unpacked->example->id, "inner-001") == 0);
        assert(unpacked->n_metadata == 2);
        assert(unpacked->data.len == 5);
        printf("  ✓ Nested message deserialized successfully\n");
        printf("  ✓ Metadata entries: %zu\n", unpacked->n_metadata);
        printf("  ✓ Binary data size: %zu\n", unpacked->data.len);
        
        example__v1__nested_example__free_unpacked(unpacked, NULL);
        free(buffer);
    }
    
    // Test 3: Repeated fields
    {
        printf("\nTest 3: Repeated fields\n");
        
        Example__V1__Example example = EXAMPLE__V1__EXAMPLE__INIT;
        example.id = "test-003";
        example.name = "Repeated Test";
        example.value = 3;
        
        char *tags[] = {"tag1", "tag2", "tag3", "tag4", "tag5"};
        example.tags = tags;
        example.n_tags = 5;
        
        // Serialize
        size_t size = example__v1__example__get_packed_size(&example);
        uint8_t *buffer = malloc(size);
        assert(buffer != NULL);
        
        example__v1__example__pack(&example, buffer);
        
        // Deserialize
        Example__V1__Example *unpacked = 
            example__v1__example__unpack(NULL, size, buffer);
        assert(unpacked != NULL);
        assert(unpacked->n_tags == 5);
        printf("  ✓ Repeated field with %zu elements\n", unpacked->n_tags);
        
        for (size_t i = 0; i < unpacked->n_tags; i++) {
            assert(unpacked->tags[i] != NULL);
            printf("  ✓ Tag[%zu]: %s\n", i, unpacked->tags[i]);
        }
        
        example__v1__example__free_unpacked(unpacked, NULL);
        free(buffer);
    }
    
    // Test 4: Enum values
    {
        printf("\nTest 4: Enum values\n");
        
        Example__V1__Example examples[3];
        Example__V1__ExampleType types[] = {
            EXAMPLE__V1__EXAMPLE_TYPE__UNSPECIFIED,
            EXAMPLE__V1__EXAMPLE_TYPE__BASIC,
            EXAMPLE__V1__EXAMPLE_TYPE__ADVANCED
        };
        const char *type_names[] = {"UNSPECIFIED", "BASIC", "ADVANCED"};
        
        for (int i = 0; i < 3; i++) {
            examples[i] = (Example__V1__Example)EXAMPLE__V1__EXAMPLE__INIT;
            examples[i].id = "enum-test";
            examples[i].name = "Enum Test";
            examples[i].value = i;
            examples[i].type = types[i];
            
            size_t size = example__v1__example__get_packed_size(&examples[i]);
            uint8_t *buffer = malloc(size);
            example__v1__example__pack(&examples[i], buffer);
            
            Example__V1__Example *unpacked = 
                example__v1__example__unpack(NULL, size, buffer);
            assert(unpacked != NULL);
            assert(unpacked->type == types[i]);
            printf("  ✓ Enum value %s (%d)\n", type_names[i], unpacked->type);
            
            example__v1__example__free_unpacked(unpacked, NULL);
            free(buffer);
        }
    }
    
    printf("\n✅ All tests passed!\n");
    return 0;
}