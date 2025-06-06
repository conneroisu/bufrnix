# Go Multiple Output Paths Example

This example demonstrates Bufrnix's **multiple output paths** feature specifically for Go microservices architecture. It shows how to generate the same protobuf code to multiple directories simultaneously, enabling shared proto definitions across different services.

## Overview

This example simulates a real-world e-commerce microservices setup with:
- **Order Service** - Handles order management
- **Payment Service** - Processes payments
- **Shared Libraries** - Common proto definitions used across services

## Multiple Output Configuration

The example demonstrates different multiple output strategies:

### 🚀 **Main Go Code Generation**
```nix
go = {
  enable = true;
  outputPath = [
    "gen/go"                      # Main generated code location
    "services/order/proto"        # Order service proto
    "services/payment/proto"      # Payment service proto  
    "services/shared/proto"       # Shared across all services
    "pkg/common/proto"            # Common package for libraries
  ];
}
```

### 🔗 **gRPC Service Generation**
```nix
grpc = {
  enable = true;
  outputPath = [
    "gen/go/grpc"
    "services/order/proto/grpc"
    "services/payment/proto/grpc"
  ];
};
```

### ✅ **Validation Generation**
```nix
validate = {
  enable = true;
  outputPath = [
    "gen/go/validate"
    "services/shared/proto/validate"
  ];
};
```

## Project Structure

```
go-multiple-outputs/
├── flake.nix                           # Bufrnix configuration
├── README.md                           # This file
├── proto/
│   ├── orders/v1/order.proto          # Order service definitions
│   ├── payments/v1/payment.proto      # Payment service definitions
│   └── google/protobuf/timestamp.proto
└── [Generated directories after nix run]
    ├── gen/go/                         # Main output
    │   ├── grpc/                       # gRPC services
    │   └── validate/                   # Validation code
    ├── services/
    │   ├── order/proto/                # Order service
    │   │   └── grpc/
    │   ├── payment/proto/              # Payment service
    │   │   └── grpc/
    │   └── shared/proto/               # Shared definitions
    │       └── validate/
    └── pkg/common/proto/               # Common library
```

## Real-World Use Cases

### 🏪 **Microservices Architecture**
Each service gets its own copy of the proto definitions:
- **Isolated deployments** - Each service can be deployed independently
- **Service boundaries** - Clear separation of concerns
- **Shared contracts** - Common proto definitions ensure compatibility

### 📦 **Library Distribution**
Generate to multiple package locations:
- **Development** - `gen/go/` for local development
- **Services** - `services/*/proto/` for service-specific usage
- **Libraries** - `pkg/common/proto/` for shared library packages

### 🔄 **CI/CD Integration**
Perfect for automated workflows:
- **Build artifacts** - Different locations for different build stages
- **Testing** - Generate test fixtures in multiple locations
- **Distribution** - Create packages for different consumers

## Proto Definitions

### Orders Service
- `Order` - Complete order information with items, addresses, and status
- `OrderService` - gRPC service for order management operations
- Full CRUD operations with pagination and filtering

### Payments Service  
- `Payment` - Payment transaction details with multiple payment methods
- `PaymentService` - gRPC service for payment processing
- Support for cards, bank transfers, and digital wallets

## Usage

### Generate Code
```bash
# Generate protobuf code to all configured locations
nix run

# Enter development environment
nix develop
```

### Verify Multiple Outputs
After generation, verify the same code exists in all locations:

```bash
# Check main outputs
ls gen/go/orders/v1/                    # Order protos
ls gen/go/payments/v1/                  # Payment protos
ls gen/go/grpc/orders/v1/               # Order gRPC
ls gen/go/grpc/payments/v1/             # Payment gRPC

# Check service-specific outputs
ls services/order/proto/orders/v1/
ls services/order/proto/grpc/orders/v1/
ls services/payment/proto/payments/v1/
ls services/payment/proto/grpc/payments/v1/

# Check shared and common outputs
ls services/shared/proto/orders/v1/
ls services/shared/proto/validate/
ls pkg/common/proto/orders/v1/
ls pkg/common/proto/payments/v1/
```

## Advanced Features

### **Plugin-Specific Paths**
Different plugins can generate to different subsets of locations:
- **Base Go code** → All 5 locations
- **gRPC services** → Only 3 locations (where services are needed)
- **Validation** → Only 2 locations (where validation is used)

### **Debug Output**
Enable debug mode to see generation progress:
```nix
debug = {
  enable = true;
  verbosity = 2;
};
```

This shows detailed logs for each output path generation.

## Benefits

1. **🎯 **Service Isolation**: Each microservice has its own proto copy
2. **📚 **Shared Libraries**: Common packages available across all services
3. **🚀 **Independent Deployments**: Services can be built and deployed separately
4. **🔄 **Code Reuse**: Same proto definitions without duplication
5. **🛠️ **Development Flexibility**: Multiple locations for different use cases
6. **📦 **Package Distribution**: Ready for Go module distribution

## Development Workflow

```bash
# 1. Modify proto definitions
vim proto/orders/v1/order.proto

# 2. Regenerate to all locations
nix run

# 3. Each service now has updated protos
cd services/order && go build ./...
cd services/payment && go build ./...

# 4. Shared libraries also updated
cd pkg/common && go build ./...
```

This example showcases how Bufrnix's multiple output paths feature enables sophisticated microservices architectures while maintaining development simplicity!