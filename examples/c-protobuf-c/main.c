#include "proto/gen/c/protobuf-c/example/v1/example.pb-c.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void print_example(const Example__V1__Example *example) {
    printf("Example {\n");
    printf("  id: %s\n", example->id);
    printf("  name: %s\n", example->name);
    printf("  value: %d\n", example->value);
    printf("  type: %s\n", 
           example->type == EXAMPLE__V1__EXAMPLE_TYPE__EXAMPLE_TYPE_BASIC ? "BASIC" :
           example->type == EXAMPLE__V1__EXAMPLE_TYPE__EXAMPLE_TYPE_ADVANCED ? "ADVANCED" : "UNSPECIFIED");
    printf("  tags: [");
    for (size_t i = 0; i < example->n_tags; i++) {
        printf("%s%s", example->tags[i], i < example->n_tags - 1 ? ", " : "");
    }
    printf("]\n");
    printf("}\n");
}

int main() {
    printf("protobuf-c Example\n");
    printf("==================\n\n");
    
    // Create and initialize an Example message
    Example__V1__Example example = EXAMPLE__V1__EXAMPLE__INIT;
    example.id = "test-123";
    example.name = "Test Example";
    example.value = 42;
    example.type = EXAMPLE__V1__EXAMPLE_TYPE__EXAMPLE_TYPE_BASIC;
    
    // Add some tags
    char *tags[] = {"important", "test", "demo"};
    example.tags = tags;
    example.n_tags = 3;
    
    printf("Original message:\n");
    print_example(&example);
    
    // Serialize the message
    size_t size = example__v1__example__get_packed_size(&example);
    uint8_t *buffer = malloc(size);
    if (!buffer) {
        fprintf(stderr, "Failed to allocate buffer\n");
        return 1;
    }
    
    size_t packed_size = example__v1__example__pack(&example, buffer);
    printf("\nSerialized message size: %zu bytes\n", packed_size);
    
    // Deserialize the message
    Example__V1__Example *unpacked = 
        example__v1__example__unpack(NULL, size, buffer);
    
    if (unpacked) {
        printf("\nDeserialized message:\n");
        print_example(unpacked);
        
        // Demonstrate nested message
        printf("\nCreating nested example...\n");
        Example__V1__NestedExample nested = EXAMPLE__V1__NESTED_EXAMPLE__INIT;
        nested.example = unpacked;
        
        // Add some metadata
        Example__V1__NestedExample__MetadataEntry entries[2];
        entries[0].key = "version";
        entries[0].value = "1.0";
        entries[1].key = "author";
        entries[1].value = "bufrnix";
        
        Example__V1__NestedExample__MetadataEntry *entry_ptrs[2] = {&entries[0], &entries[1]};
        nested.metadata = entry_ptrs;
        nested.n_metadata = 2;
        
        // Add some binary data
        uint8_t binary_data[] = {0x01, 0x02, 0x03, 0x04, 0x05};
        nested.data.data = binary_data;
        nested.data.len = sizeof(binary_data);
        
        printf("Nested example created with %zu metadata entries\n", nested.n_metadata);
        
        // Clean up
        example__v1__example__free_unpacked(unpacked, NULL);
    } else {
        fprintf(stderr, "Failed to deserialize message\n");
    }
    
    free(buffer);
    
    printf("\nExample completed successfully!\n");
    return 0;
}