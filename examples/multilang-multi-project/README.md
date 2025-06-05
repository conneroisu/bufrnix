# Multi-Language Multi-Project Enterprise Example

This example demonstrates an enterprise-scale protobuf system with multiple microservices, shared libraries, and comprehensive multi-language support. It showcases how Bufrnix can manage complex, real-world protobuf ecosystems with cross-service dependencies and multiple deployment targets.

## Overview

This example simulates a comprehensive AI/ML platform with the following services:

### Core API Services
- **Main API (`api/v1`)**: Central API gateway with comprehensive service integration
- **Chat API**: Conversational AI endpoints
- **Image API**: Image generation and processing
- **Audio API**: Audio processing and generation
- **Embedding API**: Text embedding and vector operations
- **Model Management**: Model lifecycle and configuration

### Specialized Services
- **ASR (`asr/v1`)**: Automatic Speech Recognition service
- **TTS (`tts/v1`)**: Text-to-Speech synthesis service  
- **LLM (`llm/v1`)**: Large Language Model inference service
- **Image Processing (`img/v1`)**: Advanced image manipulation
- **Text Editing (`edi/v1`)**: Text editing and correction
- **Embeddings (`emb/v1`)**: Vector embedding generation
- **Segmentation (`seg/v1`)**: Text and data segmentation
- **Video (`vid/v1`)**: Video generation and processing
- **Variations (`vari/v1`)**: Content variation generation

### Shared Libraries
- **Language (`lib/lang.proto`)**: ISO 639-1 language code definitions
- **Media (`lib/media.proto`)**: Common media type definitions and formats

## Architecture Highlights

### Multi-Service Design
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Main API      │    │   Chat Service  │    │  Image Service  │
│   (Gateway)     │◄──►│                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  ASR Service    │    │  TTS Service    │    │  LLM Service    │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  ▼
                    ┌─────────────────────────┐
                    │    Shared Libraries     │
                    │  (Language, Media)      │
                    └─────────────────────────┘
```

### Language Support Matrix

| Language | Basic Proto | gRPC | Gateway | OpenAPI | Type Safety | Performance |
|----------|-------------|------|---------|---------|-------------|-------------|
| **Go** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (vtprotobuf) |
| **Python** | ✅ | ✅ | ❌ | ❌ | ✅ (mypy) | ⚡ |
| **JavaScript** | ✅ | ✅ | ❌ | ❌ | ⚡ (ES modules) | ⚡ |
| **Swift** | ✅ | ✅ | ❌ | ❌ | ✅ | ⚡ |
| **Dart** | ✅ | ✅ | ❌ | ❌ | ✅ | ⚡ |
| **C++** | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ |

## Getting Started

### Prerequisites
- Nix with flakes enabled
- Git

### Quick Start
```bash
# Navigate to the example
cd examples/multilang-multi-project

# Generate all protobuf code for all languages
nix build

# Explore generated code
ls proto/gen/
```

### Language-Specific Development

#### Go Development
```bash
# Enter Go development environment
nix develop .#go

# Run the Go example
go run main.go

# Or use the pre-built app
nix run .#go-example
```

#### Python Development
```bash
# Enter Python development environment
nix develop .#python

# Install dependencies
pip install -r requirements.txt

# Run the Python example
python main.py

# Or use the pre-built app
nix run .#python-example
```

#### JavaScript Development
```bash
# Enter JavaScript development environment
nix develop .#javascript

# Install dependencies
npm install

# Run the JavaScript example
npm start

# Or use the pre-built app
nix run .#javascript-example
```

## Generated Code Structure

```
proto/gen/
├── go/                     # Go packages with full gRPC support
│   ├── api/v1/            # Main API with gateway integration
│   ├── asr/v1/            # Speech recognition service
│   ├── lib/               # Shared library types
│   └── ...
├── python/                # Python modules with type stubs
│   ├── api/v1/            # API modules
│   ├── lib/               # Shared library modules
│   └── ...
├── js/                    # JavaScript ES modules
│   ├── api/v1/            # API modules
│   ├── lib/               # Library modules
│   └── ...
├── swift/                 # Swift packages
├── dart/                  # Dart packages for Flutter
├── cpp/                   # C++ libraries
├── doc/                   # HTML documentation
└── openapi/               # OpenAPI/Swagger specifications
    ├── api/v1/            # API specifications
    └── ...
```

## Real-World Usage Patterns

### 1. Microservice Communication
```go
// Go service calling another service
client := apipb.NewChatServiceClient(conn)
response, err := client.CreateChatCompletion(ctx, &apipb.CreateChatCompletionRequest{
    Model: "gpt-4",
    Messages: []*apipb.ChatCompletionRequestMessage{
        {Role: apipb.ChatMessageRole_CHAT_MESSAGE_ROLE_USER, Content: "Hello"},
    },
})
```

### 2. Cross-Language Data Exchange
```python
# Python service processing Go-generated data
from api.v1 import api_pb2

# Deserialize data from Go service
request = api_pb2.CreateChatCompletionRequest()
request.ParseFromString(go_service_data)

# Process and forward to another service
response = llm_service.process(request)
```

### 3. Frontend Integration
```javascript
// JavaScript frontend consuming API
import { CreateImageRequest, ImageSize } from './proto/gen/js/api/v1/api_pb.js';

const request = new CreateImageRequest({
    prompt: "A beautiful landscape",
    size: ImageSize.IMAGE_SIZE_1024X1024,
    n: 1
});

const response = await fetch('/api/v1/images', {
    method: 'POST',
    body: request.serializeBinary()
});
```

## Enterprise Features

### 1. API Documentation
Automatic generation of comprehensive API documentation:
- HTML documentation in `proto/gen/doc/`
- OpenAPI specifications in `proto/gen/openapi/`
- Interactive Swagger UI integration

### 2. Type Safety Across Languages
- Go: Native strong typing with compile-time checks
- Python: mypy type stubs for static analysis
- JavaScript: TypeScript definitions (when applicable)
- Rust: Memory-safe types with compile-time guarantees

### 3. Performance Optimizations
- **Go**: vtprotobuf for faster serialization
- **Rust**: Zero-copy deserialization with tonic
- **C++**: Native performance for compute-intensive tasks

### 4. Development Workflow Integration
```bash
# Lint protobuf files
nix flake check

# Format protobuf files
buf format proto/src --write

# Generate code for specific language
nix build .#go-example
```

## Advanced Configuration

### Custom Plugin Integration
The `flake.nix` demonstrates advanced plugin configurations:

```nix
go = {
  enable = true;
  outputPath = "proto/gen/go";
  
  # Multiple plugin configurations
  grpc.enable = true;
  gateway.enable = true;
  openapiv2.enable = true;
  vtprotobuf = {
    enable = true;
    options = ["features=marshal+unmarshal+size+pool"];
  };
};
```

### Multi-Environment Support
Different development shells for different purposes:
- `.#go` - Go-specific tooling
- `.#python` - Python development with linting
- `.#javascript` - Node.js and TypeScript tools
- `.#docs` - Documentation generation tools

## Integration Examples

### Docker Deployment
```dockerfile
FROM nixos/nix

# Copy and build the protobuf code
COPY . /app
WORKDIR /app
RUN nix build

# Use generated code in your application
COPY --from=builder /app/result/proto/gen /proto/gen
```

### CI/CD Pipeline
```yaml
# .github/workflows/proto.yml
name: Protobuf Generation
on: [push, pull_request]

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v22
      - run: nix build
      - run: nix flake check  # Lint and format checks
```

## Performance Considerations

### Optimization Strategies
1. **Language Selection by Use Case**:
   - Go: High-performance services and gateways
   - Python: Data processing and ML workflows
   - Swift: iOS/macOS applications
   - JavaScript: Frontend and Node.js services

2. **Message Design**:
   - Shared library types reduce duplication
   - Streaming APIs for large data transfers
   - Proper field numbering for backward compatibility

3. **Code Generation Optimization**:
   - vtprotobuf for Go performance critical paths
   - Mypy stubs for Python type checking
   - Swift's strong type system for mobile apps

## Troubleshooting

### Common Issues
1. **Import Path Problems**: Ensure `sourceDirectories` and `includeDirectories` are correctly configured
2. **Missing Dependencies**: Use language-specific development shells
3. **Version Conflicts**: Pin protobuf versions in language package managers

### Debug Commands
```bash
# Verify protobuf compilation
buf build proto/src

# Check generated code
ls -la proto/gen/

# Test language-specific imports
nix develop .#go -c go mod tidy
nix develop .#python -c python -c "import api.v1.api_pb2"
```

## Next Steps

1. **Add Authentication**: Integrate JWT or OAuth2 with gRPC interceptors
2. **Monitoring**: Add OpenTelemetry protobuf definitions
3. **Testing**: Create language-specific test suites using generated code
4. **Deployment**: Integrate with Kubernetes using generated Helm charts

## Related Examples

- [Basic multilang example](../multilang/) - Simpler multi-language setup
- [Individual language examples](../) - Deep dives into specific languages
- [Bufrnix documentation](../../doc/) - Complete configuration reference

This example represents a production-ready template for large-scale protobuf systems with multi-language support, comprehensive tooling, and enterprise-grade features.