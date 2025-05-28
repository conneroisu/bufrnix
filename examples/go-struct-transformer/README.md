# Go Struct Transformer Example

This example demonstrates how to use `protoc-gen-struct-transformer` with bufrnix to generate transformation functions between Protocol Buffer messages and business logic structs.

## Overview

The `protoc-gen-struct-transformer` plugin solves a common architectural problem in gRPC applications: maintaining clean separation between transport layer (protobuf) and business logic layer (domain models).

## Architecture Benefits

- **Clean Separation**: Protobuf structs stay in the transport layer, business logic uses domain models
- **Easier Testing**: Business logic can be tested without protobuf dependencies
- **Independent Evolution**: Transport and domain models can evolve separately
- **Type Safety**: Generated functions provide compile-time safety for transformations

## Project Structure

```
├── flake.nix                    # Nix configuration with struct-transformer enabled
├── proto/
│   └── example/v1/
│       └── product.proto        # Protobuf definitions with transformer annotations
├── models/
│   └── models.go               # Business logic struct definitions
├── gen/
│   ├── go/                     # Generated protobuf code
│   └── transform/              # Generated transformation functions (when working)
├── main.go                     # Example usage
└── go.mod
```

## Key Files

### proto/example/v1/product.proto

Defines the protobuf messages with annotations that tell the transformer which business logic structs to map to.

### models/models.go

Contains the business logic structs (`ProductModel`, `ProductListModel`) with domain-specific methods and fields that don't exist in the protobuf.

### Generated Transformation Functions (when fully working)

The plugin would generate functions like:

- `ProductModelToPbVal()` - Convert business model to protobuf value
- `PbToProductModelPtr()` - Convert protobuf to business model pointer
- `ProductModelToPbValList()` - Convert slice of models to protobuf slice
- And 11 other variants covering all pointer/value/list combinations

## Running the Example

```bash
# Enter the development environment
nix develop

# Generate protobuf code and transformation functions
nix build

# Run the example
go mod tidy
go run main.go
```

## Current Status

This example demonstrates a **fully working** integration of `protoc-gen-struct-transformer` with bufrnix!

**What's Working:**

- ✅ The `protoc-gen-struct-transformer` package builds from source (v1.0.8)
- ✅ The plugin executes during protobuf generation
- ✅ Standard protobuf Go code is generated successfully
- ✅ Annotation proto files are included and working
- ✅ Transformation functions are generated for all configured messages
- ✅ The example compiles and runs successfully with full transformations
- ✅ All 14 transformation function variants are generated per message

**Key Features Demonstrated:**

1. **Bidirectional Transformations**: Convert between protobuf and business logic structs
2. **Field Mapping**: The `stock_quantity` field maps to `Stock` in the model
3. **Field Skipping**: The `internal_field` is skipped in transformations
4. **Nested Transformations**: ProductList contains Products that are also transformed
5. **Clean Architecture**: Complete separation between transport and domain layers

## Configuration in bufrnix

The struct-transformer is configured in the flake.nix:

```nix
languages.go = {
  enable = true;
  structTransformer = {
    enable = true;
    goRepoPackage = "models";        # Package name for business models
    goProtobufPackage = "proto";     # Package name for protobuf code
    goModelsFilePath = "models/models.go";  # Path to business struct definitions
    outputPackage = "transform";     # Package name for generated functions
  };
};
```

## Real-World Usage

In a production environment, the generated transformation functions would be used like:

```go
// In a gRPC handler
func (s *ProductService) GetProduct(ctx context.Context, req *examplev1.GetProductRequest) (*examplev1.Product, error) {
    // Business logic uses domain models
    product, err := s.productRepo.GetByID(req.Id)
    if err != nil {
        return nil, err
    }

    // Transform business model to protobuf for transport
    return transform.ProductModelToPbPtr(product), nil
}

// In business logic
func ProcessOrder(products []*examplev1.Product) error {
    // Transform protobuf to business models
    domainProducts := transform.PbToProductModelValList(products)

    // Use business logic methods
    for _, product := range domainProducts {
        if !product.IsInStock() {
            return errors.New("product out of stock")
        }
    }

    return nil
}
```

This pattern is especially valuable in larger applications where you want to:

- Keep protobuf concerns isolated to API boundaries
- Add business logic methods to domain models
- Maintain clean, testable business logic
- Evolve domain and transport models independently
