# Multi-Language Multi-Project Example

This example demonstrates an enterprise-scale AI platform architecture using Protocol Buffers and gRPC. It showcases how Bufrnix can manage complex, real-world protobuf ecosystems with multiple microservices, shared libraries, and comprehensive multi-language support across 7+ programming languages.

## Overview

This example models a comprehensive AI platform ("Pegwings") with the following architecture:
- **API Gateway**: Unified entry point routing to specialized microservices
- **Multiple Microservices**: Chat/LLM, Image Generation, Text-to-Speech, Speech Recognition, Video Generation, and more
- **Shared Libraries**: Common types for media formats, language codes, and authentication
- **Multi-Language Support**: Generated code for Go, Python, JavaScript/TypeScript, Swift, Dart, C++, and documentation
- **Enterprise Features**: Authentication, usage tracking, administrative tools, and educational components

## Architecture

### Service Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                        API Gateway                              │
│                   (APIService - api.proto)                      │
└────────────┬────────────────────────────────────┬──────────────┘
             │                                    │
┌────────────┴────────────┐          ┌───────────┴────────────┐
│   Chat/LLM Service      │          │   Image Service         │
│   (llm.proto)           │          │   (img.proto)           │
│   - Completions         │          │   - Generation          │
│   - Streaming           │          │   - Editing             │
│   - Function Calling    │          │   - Variations          │
└─────────────────────────┘          └───────────────────────┘
             │                                    │
┌────────────┴────────────┐          ┌───────────┴────────────┐
│   TTS Service           │          │   ASR Service           │
│   (tts.proto)           │          │   (asr.proto)           │
│   - Text-to-Speech      │          │   - Speech-to-Text      │
│   - Multiple Voices     │          │   - Transcription       │
└─────────────────────────┘          └───────────────────────┘
```

### Microservices

1. **API Gateway** (`api/v1/api.proto`)
   - Unified REST/gRPC interface
   - Request routing and aggregation
   - Authentication and rate limiting
   - Administrative endpoints

2. **Chat/LLM Service** (`llm/v1/llm.proto`)
   - AI chat completions with streaming support
   - Function calling and tool use
   - Response formatting and logprobs
   - Usage tracking and model selection

3. **Image Services**
   - **Generation** (`img/v1/img.proto`): Text-to-image generation
   - **Editing** (`edi/v1/edit.proto`): Image modification
   - **Segmentation** (`seg/v1/seg.proto`): Object detection and segmentation
   - **Variations** (`vari/v1/vari.proto`): Generate image variations

4. **Audio Services**
   - **Text-to-Speech** (`tts/v1/tts.proto`): Convert text to natural speech
   - **Speech Recognition** (`asr/v1/asr.proto`): Transcribe audio to text

5. **Other Services**
   - **Embeddings** (`emb/v1/emb.proto`): Text embeddings for semantic search
   - **Video Generation** (`vid/v1/vid.proto`): Generate videos from prompts

### Shared Libraries

- **Media Types** (`lib/media.proto`)
  - Common image sizes and formats
  - Audio formats (MP3, Opus, AAC, FLAC, WAV, PCM)
  - Shared across all media-handling services

- **Language Codes** (`lib/lang.proto`)
  - Comprehensive ISO 639-1 language enum
  - Used by TTS, ASR, and translation services

## Project Structure

```
multilang-multi-project/
├── proto/
│   ├── src/                    # Source protobuf definitions
│   │   ├── api/v1/            # API gateway service
│   │   ├── llm/v1/            # Chat/LLM service
│   │   ├── img/v1/            # Image generation service
│   │   ├── tts/v1/            # Text-to-speech service
│   │   ├── asr/v1/            # Speech recognition service
│   │   ├── emb/v1/            # Embeddings service
│   │   ├── vid/v1/            # Video generation service
│   │   └── lib/               # Shared libraries
│   │       ├── lang.proto     # Language codes
│   │       └── media.proto    # Media types
│   │
│   ├── lib/                   # Third-party dependencies
│   │   ├── google/api/        # Google API annotations
│   │   ├── buf/validate/      # Validation rules
│   │   └── gateway/           # gRPC-Gateway annotations
│   │
│   └── gen/                   # Generated code (after build)
│       ├── go/                # Go packages with gRPC, Gateway, OpenAPI
│       ├── python/            # Python modules with type stubs
│       ├── js/                # JavaScript/TypeScript modules
│       ├── swift/             # Swift packages
│       ├── dart/              # Dart packages
│       ├── cpp/               # C++ libraries with CMake support
│       ├── doc/               # HTML documentation
│       └── openapi/           # OpenAPI/Swagger specifications
│
├── examples/                  # Language-specific client examples
│   ├── go/                   # Go client implementation
│   ├── python/               # Python client implementation
│   └── javascript/           # JavaScript/TypeScript client
│
└── flake.nix                 # Bufrnix configuration
```

## Generated Code Features

### Go
- Standard protobuf and gRPC code generation
- gRPC-Gateway for REST API support
- OpenAPI/Swagger specification generation
- VTProtobuf for performance optimization
- JSON marshaling support

### Python
- Type-safe protobuf and gRPC stubs
- MyPy type hints (`.pyi` files)
- Async support ready

### JavaScript/TypeScript
- ES module support
- TypeScript definitions
- Compatible with modern bundlers

### Swift
- Native Swift protobuf implementation
- gRPC client support
- iOS/macOS compatible

### Dart
- Flutter-ready packages
- gRPC client support
- Null-safety enabled

### C++
- CMake integration helpers
- gRPC support
- Header and implementation files

## Usage

### Building All Languages

```bash
# Generate code for all configured languages
nix build

# Enter development shell with all tools
nix develop
```

### Language-Specific Development

```bash
# Go development
nix develop .#go

# Python development
nix develop .#python

# JavaScript/TypeScript development
nix develop .#javascript

# Documentation generation
nix develop .#docs
```

### Running Examples

After building, you can run the language-specific examples:

```bash
# Go example
cd examples/go
go run main.go

# Python example
cd examples/python
python main.py

# JavaScript example
cd examples/javascript
npm install
node index.js
```

## Key Features Demonstrated

1. **Service Decomposition**: Shows how to split a large API into focused microservices
2. **Shared Types**: Demonstrates code reuse through shared protobuf libraries
3. **Gateway Pattern**: API gateway aggregating multiple backend services
4. **Multi-Language**: Simultaneous code generation for 7+ languages
5. **Documentation**: Automatic HTML and OpenAPI documentation generation
6. **Performance**: VTProtobuf optimization for Go
7. **Type Safety**: Full typing support in all generated languages
8. **Modern Standards**: ES modules, TypeScript, Swift 5, Dart null-safety

## Configuration Highlights

The `flake.nix` demonstrates advanced Bufrnix features:

- Multiple source and include directories
- Selective file compilation
- Language-specific plugin configuration
- Custom output paths per language
- Performance optimizations (VTProtobuf)
- Documentation generation
- OpenAPI specification generation

## Best Practices Shown

1. **Version in Path**: All services use `/v1/` in their package names
2. **Consistent Naming**: Services follow `[domain]/v1/[service].proto` pattern
3. **Shared Libraries**: Common types extracted to `lib/` directory
4. **Import Management**: Clean separation between source and third-party protos
5. **Multi-Plugin Support**: Combining multiple plugins per language (e.g., Go with gRPC + Gateway + OpenAPI)

## Development Workflow

1. **Modify Protos**: Edit files in `proto/src/`
2. **Regenerate**: Run `nix build` to regenerate all code
3. **Test**: Use language-specific development shells to test changes
4. **Integrate**: Import generated packages in your applications

This example provides a production-ready template for large-scale protobuf projects with multiple teams, services, and deployment targets.
