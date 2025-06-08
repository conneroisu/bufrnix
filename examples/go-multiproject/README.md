# Go Multi-Project Protobuf Example

This example demonstrates how to use bufrnix to generate Go code from multiple protobuf files across different packages/modules in a single project. It showcases a realistic e-commerce scenario with separate proto files for users, products, and orders.

## Project Structure

```
go-multiproject/
├── flake.nix                    # Nix flake configuration
├── go.mod                       # Go module definition
├── main.go                      # Example Go application
├── README.md                    # This file
└── proto/
    ├── users/v1/
    │   └── user.proto          # User service definitions
    ├── products/v1/
    │   └── product.proto       # Product service definitions
    ├── orders/v1/
    │   └── order.proto         # Order service definitions (references users & products)
    └── gen/                    # Generated Go code output directory
```

## Proto Files Overview

### Users (`proto/users/v1/user.proto`)

- Defines `User` message with fields like id, email, name, timestamps, and status
- Includes `UserService` with CRUD operations
- Contains `UserStatus` enum for user states

### Products (`proto/products/v1/product.proto`)

- Defines `Product` message with pricing, inventory, and categorization
- Includes `ProductService` with search and inventory management
- Contains `ProductStatus` enum and `ProductCategory` message

### Orders (`proto/orders/v1/order.proto`)

- Defines `Order` message that references users and products
- Includes complex order management with items, shipping, and status tracking
- Demonstrates cross-package imports and relationships
- Contains `OrderService` with order lifecycle management

## Key Features Demonstrated

1. **Multi-package Organization**: Shows how to organize proto files across logical domains
2. **Cross-package References**: Orders reference both users and products
3. **Complex Message Types**: Nested messages, repeated fields, and enums
4. **Service Definitions**: gRPC service definitions with various RPC methods
5. **Timestamp Usage**: Integration with Google's well-known types
6. **Go Package Structure**: Proper Go package naming and imports

## Usage

### 1. Generate Proto Code

```bash
# Build the protobuf files using bufrnix
nix build

# Or enter the development shell and build manually
nix develop
# The generated files will be in proto/gen/go/
```

### 2. Run the Example

```bash
# Enter the development environment
nix develop

# Run the Go example
go run main.go
```

The example application will:

- Create sample user, product, and order instances
- Demonstrate message creation and field access
- Show cross-package references in action
- Display various service request examples

### 3. Explore Generated Code

After building, explore the generated Go code in:

- `proto/gen/go/users/v1/` - User-related generated code
- `proto/gen/go/products/v1/` - Product-related generated code
- `proto/gen/go/orders/v1/` - Order-related generated code

## Configuration Details

The `flake.nix` configuration:

- Specifies multiple proto files in the `files` array
- Uses `includeDirectories` to set the proto search path
- Enables Go code generation with gRPC support
- Outputs to `proto/gen/go` directory

## Extending the Example

To add more proto files:

1. Create new `.proto` files in appropriate directories
2. Add the file paths to the `files` array in `flake.nix`
3. Import other proto files using their relative paths
4. Rebuild with `nix build`

This example serves as a template for real-world multi-service protobuf projects using bufrnix.
