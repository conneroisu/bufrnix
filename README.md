# bufrnix

Nix powered protobufs with developer tooling: cli, linter, formatter, lsp, etc.

## Introduction


Example Usage:
```nix
{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        bufrnix.url = "github:conneroisu/bufr.nix";
        bufr.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = inputs @ {
        self, 
        nixpkgs,
        bufr,
        ...
    }: {
        bufrnix = {
            root = "./proto"; # root of versioned protobuf files
            go = {
                protoc-gen-go = {
                    enable = true;
                    out = "gen/go"; # (Default) output directory relative to root
                    opt = {
                        "paths=source_relative";
                    };
                };
            };
            python = {
                enable = true;
                out = "gen/python"; # (Default) output directory relative to root
            };
        };
    }
}
```

Each step has:
- `out` (similar to `buf.build`) (e.g. `--prost-serde_out="$PROTOC_RUST_OUT"`)
- `opt` (similar to `buf.build`) (e.g. `--prost-crate_opt=gen_crate,no_features=true`)

- `package`

Defining new proto dependencies is simple as settings in nix.

```nix
# TODO: add example
```

## Diving Deeper

CLI = script

# Plan 
# Comprehensive Bufrnix Blueprint

## Executive Summary

Bufrnix is a Nix-powered Configurable Protobuf Nix Package that uses protoc for all code generation while providing hermetic, declarative builds and robust debugging capabilities.

### Core Vision
Create a Nix package that combines the best of protoc for code generation and Buf CLI for linting, providing a complete, hermetic, and declarative Protobuf development solution.

### Key Features
- **Standalone package** 
- **Pure Nix package pattern** compatible with any Nix workflow
- **protoc for all code generation** with Buf only for linting
- **Built-in wrapper commands** for common operations
- **Hermetic environment** for reproducible builds
- **Comprehensive language support** for Go, PHP (with Twirp), Python, Rust, and custom plugins
- **Advanced debugging capabilities** for troubleshooting
- **Performance optimizations** through caching and incremental generation
- **Testing framework** for validating generated code
- **Documentation generation** from proto files
- **CI/CD integration** templates for popular platforms

---

## 1. Architecture

### 1.1 High-Level Overview
```plaintext
[flake.nix]
  └──> [bufrnix package]
         └──> [mkBufrnixPackage function]
               ├── Creates a standalone package with protoc, Buf tools and wrappers
               ├── Provides executables for common Protobuf operations
               ├── Configures debug capabilities if enabled
               └── Includes testing, documentation, and CI integration

[Your project's flake.nix]
  └──> [integrations]
         ├── Import bufrnix package directly
         ├── Use as direct dependency in any context (not just devShell)
         └── Can be used as a buildInput, dependency, or standalone tool
```

### 1.2 Project Structure
```plaintext
/src/lib/
    bufrnix-options.nix    # All Nix module options (languages, debug, etc.)
    mkBufrnix.nix          # Constructs the bufrnix package
    utils/
      debug.nix            # Debug utilities and functions
      cache.nix            # Cache implementation
      error-handling.nix   # Enhanced error handling
      incremental.nix      # Incremental generation
      testing.nix          # Testing framework
      ci.nix               # CI/CD integration helpers

/doc/src/
    getting-started.md     # How to use as a standalone package
    language-guides/       # Detailed guides for each language
    debug/
    testing/
    performance/
    security/
    ci-cd/
    migration/

/examples/
    standalone/            # Example using bufrnix directly
    go-python/             # Example project with Go and Python
    rust-protobuf/         # Example project with Rust
    with-ci/               # Example with CI integration
    with-testing/          # Example with testing

/tests/                    # Framework tests
    unit/
    integration/
    performance/
    compatibility/
```

---

## 2. Module Options

### 2.1 Proto Configuration
```nix
protos = {
  sourceDirectories = mkOption {
    type = types.listOf types.str;
    default = [ "./proto" ];
    description = "Directories containing proto files to compile";
  };
  
  includeDirectories = mkOption {
    type = types.listOf types.str;
    default = [ "./proto" ];
    description = "Directories to include in the include path";
  };
  
  files = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Specific proto files to compile (leave empty to compile all)";
  };
};
```

### 2.2 Buf Module Configuration (for linting)
```nix
module = {
  root = mkOption {
    type = types.str;
    default = "./proto";
    description = "Root directory containing proto files";
  };
  
  lint = {
    use = mkOption {
      type = types.listOf types.str;
      default = [ "STANDARD" ];
      description = "Lint rule categories to use";
    };
    
    except = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Lint rules or categories to exclude";
    };
    
    ignore = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Directories or files to exclude from linting";
    };
  };
  
  breaking = {
    use = mkOption {
      type = types.listOf types.str;
      default = [ "FILE" ];
      description = "Breaking change rule categories to use";
    };
    
    except = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Breaking change rules or categories to exclude";
    };
    
    ignore = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Directories or files to exclude from breaking change detection";
    };
  };
};
```

### 2.3 Language Configuration
```nix
languages = {
  go = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Go code generation";
    };
    
    outputPath = mkOption {
      type = types.str;
      default = "gen/go";
      description = "Output directory for generated Go code";
    };
    
    options = mkOption {
      type = types.listOf types.str;
      default = [ "paths=source_relative" ];
      description = "Options to pass to protoc-gen-go";
    };
    
    packagePrefix = mkOption {
      type = types.str;
      default = "";
      description = "Go package prefix for generated code";
    };
    
    grpc = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Go gRPC code generation";
      };
    };
  };
  
  python = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Python code generation";
    };
    
    outputPath = mkOption {
      type = types.str;
      default = "gen/python";
      description = "Output directory for generated Python code";
    };
    
    options = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Options to pass to Python plugin";
    };
    
    grpc = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Python gRPC code generation";
      };
    };
  };
  
  rust = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Rust code generation";
    };
    
    outputPath = mkOption {
      type = types.str;
      default = "gen/rust";
      description = "Output directory for generated Rust code";
    };
    
    options = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Options to pass to Rust plugin";
    };
    
    tonic = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Rust tonic (gRPC) code generation";
      };
    };
  };
  
  custom = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom plugin code generation";
    };
    
    plugins = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "List of custom plugins to use";
      example = literalExpression ''
        [
          {
            name = "custom-plugin";
            path = "./plugins/protoc-gen-custom";
            outputPath = "gen/custom";
            options = [ "option1=value1" ];
          }
        ]
      '';
    };
  };
};
```

### 2.4 Performance and Caching Options
```nix
cache = {
  enable = mkOption {
    type = types.bool;
    default = true;
    description = "Enable cache for code generation";
  };
  
  directory = mkOption {
    type = types.str;
    default = ".bufrnix-cache";
    description = "Directory to store cache";
  };
  
  ttl = mkOption {
    type = types.int;
    default = 604800; # 7 days in seconds
    description = "Time to live for cache entries (in seconds)";
  };
};

incremental = {
  enable = mkOption {
    type = types.bool;
    default = true;
    description = "Enable incremental code generation";
  };
};
```

### 2.5 Testing, Documentation, and Debug Options
```nix
testing = {
  enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable testing of generated code";
  };
  
  frameworks = mkOption {
    type = types.attrsOf types.bool;
    default = {
      go = false;
      python = false;
      rust = false;
    };
    description = "Enable testing for specific language frameworks";
  };
  
  testDir = mkOption {
    type = types.str;
    default = "tests";
    description = "Directory for test files";
  };
};

docs = {
  enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable documentation generation from proto files";
  };
  
  format = mkOption {
    type = types.enum [ "markdown" "html" "json" ];
    default = "markdown";
    description = "Format of generated documentation";
  };
  
  outputDir = mkOption {
    type = types.str;
    default = "docs/protos";
    description = "Output directory for documentation";
  };
};

debug = {
  enable = mkEnableOption "Enable debug mode";
  
  verbosity = mkOption {
    type = types.enum [ "low" "medium" "high" "trace" ];
    default = "medium";
    description = "Debug verbosity level";
  };
  
  logFile = mkOption {
    type = types.str;
    default = ".bufrnix-debug.log";
    description = "Path to debug log file";
  };
  
  showCommands = mkOption {
    type = types.bool;
    default = true;
    description = "Show protoc commands being executed";
  };
  
  dryRun = mkOption {
    type = types.bool;
    default = false;
    description = "Print commands without executing them";
  };
  
  stackTraces = mkOption {
    type = types.bool;
    default = false;
    description = "Include stack traces in error logs";
  };
};
```

### 2.6 CI/CD Options
```nix
ci = {
  enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable CI/CD integration";
  };
  
  generateWorkflows = mkOption {
    type = types.bool;
    default = true;
    description = "Generate CI/CD workflow files";
  };
  
  platforms = mkOption {
    type = types.listOf (types.enum [ "github" "gitlab" "azure" "jenkins" ]);
    default = [ "github" ];
    description = "CI/CD platforms to generate workflows for";
  };
};
```

---

## 3. Core Functionality

### 3.1 Command-Line Interfaces
```bash
# Initialize a new module (creates default proto directory structure)
$ bufrnix_init

# Generate protobuf code using protoc (with all configured plugins)
$ bufrnix_generate

# Generate protobuf code incrementally (only changed files)
$ bufrnix_generate --incremental

# Lint proto files with buf
$ bufrnix_lint

# Format proto files with buf
$ bufrnix_format

# Detect breaking changes against a version with buf
$ bufrnix_breaking --against "../../.git#subdir=proto"

# Run tests on generated code
$ bufrnix_test

# Generate documentation from proto files
$ bufrnix_docs

# Check environment setup
$ bufrnix_doctor

# Run performance benchmark
$ bufrnix_benchmark

# Check for security issues in dependencies
$ bufrnix_audit

# Generate CI/CD workflows
$ bufrnix_ci

# Clear cache
$ bufrnix_clear-cache
```

### 3.2 Generated Protoc Command Example
```bash
protoc \
  -I=./proto \
  -I=./third_party/proto \
  --go_out=gen/go \
  --go_opt=paths=source_relative \
  --go-grpc_out=gen/go \
  --go-grpc_opt=paths=source_relative \
  --python_out=gen/python \
  --prost_out=gen/rust \
  ./proto/service/v1/*.proto
```

### 3.3 Debug Mode
Debug mode is controlled by environment variables:

```bash
export BUFRNIX_DEBUG=1
export BUFRNIX_VERBOSITY=high
export BUFRNIX_LOGFILE=.bufrnix-debug.log
export BUFRNIX_SHOW_COMMANDS=1
export BUFRNIX_DRYRUN=0
export BUFRNIX_STACK_TRACES=1
```

Debug mode provides:
- Verbose logging of commands
- Output redirection to a log file
- Dry-run option to preview commands without execution
- Enhanced error reporting with contextual information
- Stack traces for deep debugging
- Performance metrics for command execution
- Detailed plugin execution information

---

## 4. Implementation

### 4.1 Example `flake.nix`
```nix
{
  description = "bufrnix: Nix-powered protobuf package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      
      # Create a bufrnix package based on configuration
      mkBufrnixPackage = system: config:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          
          # Process the configuration
          bufConfig = {
            inherit (config) protos module languages debug;
            cache = config.cache or { enable = true; directory = ".bufrnix-cache"; ttl = 604800; };
            incremental = config.incremental or { enable = true; };
            testing = config.testing or { enable = false; };
            docs = config.docs or { enable = false; };
            ci = config.ci or { enable = false; };
          };
          
          # The package implementation (full implementation in the blueprint)
          bufrnixPackage = pkgs.symlinkJoin {
            name = "bufrnix";
            paths = with pkgs; [
              # Core tools
              buf
              protobuf
              protoc-gen-go
              protoc-gen-go-grpc
              python3Packages.grpcio-tools
              protobuf-rust
              
              # Optional tools
              (lib.optional (bufConfig.testing.enable) testingTools)
              (lib.optional (bufConfig.ci.enable) ciTools)
              (lib.optional ((bufConfig.cache or {}).enable or true) cacheTools)
              (lib.optional (bufConfig.docs.enable) docTools)
            ];
            
            # Create wrapper scripts
            buildInputs = [ pkgs.makeWrapper ];
            
            # Post-build script to create wrappers
            postBuild = ''
              # Create wrapper scripts and configuration
              # ... (full implementation in the blueprint)
            '';
          };
        in bufrnixPackage;
    in {
      overlays.default = final: prev: {
        # Exported packages
        bufrnix = self.packages.${prev.system}.default;
      };
      
      # Create packages for all systems
      packages = forAllSystems (system: {
        default = mkBufrnixPackage system {
          # Default configuration
          # ... (full implementation in the blueprint)
        };
        
        # Allow creating custom configurations
        mkBufrnixPackage = config: mkBufrnixPackage system config;
      });
      
      # Export library function
      lib.mkBufrnixPackage = system: config: mkBufrnixPackage system config;
    };
}
```

### 4.2 Integration Examples

#### Direct Use as a Package
```nix
# In your project's flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:example/bufrnix";
  };

  outputs = { self, nixpkgs, bufrnix }: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Create a custom bufrnix package with your configuration
      myBufrnix = bufrnix.packages.${system}.mkBufrnixPackage {
        # Configuration options
        # ... (example in the blueprint)
      };
    in {
      # Option 1: Just expose it as a package
      packages.${system}.default = myBufrnix;
      
      # Option 2: Add it to devShell (optional)
      devShells.${system}.default = pkgs.mkShell {
        packages = [ myBufrnix ];
      };
      
      # Option 3: Use it in a derivation
      packages.${system}.myProject = pkgs.stdenv.mkDerivation {
        name = "my-proto-project";
        src = ./.;
        
        nativeBuildInputs = [ myBufrnix ];
        
        buildPhase = ''
          bufrnix_init
          bufrnix_generate
          bufrnix_docs
          bufrnix_test
        '';
        
        installPhase = ''
          mkdir -p $out/{gen,docs}
          cp -r gen $out/
          cp -r docs $out/
        '';
      };
    };
}
```

#### Using with Overlay
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:example/bufrnix";
  };

  outputs = { self, nixpkgs, bufrnix }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ bufrnix.overlays.default ];
      };
    in {
      packages.${system}.default = pkgs.bufrnix;
    };
}
```

---

## 5. Advanced Features

### 5.1 Caching and Performance
Bufrnix includes a caching system to avoid regenerating unchanged proto files:

1. **File-level Caching**
   - Cache generated files based on proto file content hash
   - Invalidate cache when proto files change

2. **Dependency-aware Caching**
   - Track dependencies between proto files
   - Only regenerate affected files when dependencies change

3. **Incremental Generation**
   - Generate only changed files and their dependents
   - Track files that need regeneration

4. **Benchmark Tools**
   - Measure code generation performance
   - Compare performance between versions

### 5.2 Testing Framework
The testing framework validates that generated code works correctly:

1. **Unit Tests**
   - Tests for individual message types and services
   - Type validation and serialization/deserialization tests

2. **Integration Tests**
   - Tests with actual service implementations
   - Client-server communication tests

3. **Framework Integration Tests**
   - Tests with popular frameworks (gRPC, Connect, Twirp)
   - Language-specific framework tests

4. **Compatibility Tests**
   - Cross-language tests (e.g., Go client with Python server)
   - Backward compatibility tests

5. **Performance Tests**
   - Benchmark serialization/deserialization performance
   - Service call performance tests

### 5.3 CI/CD Integration
CI/CD integration ensures consistent proto handling across environments:

1. **Workflow Generation**
   - Generate workflows for popular CI/CD platforms
   - Customize workflows based on project needs

2. **Validation Steps**
   - Lint proto files
   - Check for breaking changes
   - Run tests on generated code

3. **Artifact Generation**
   - Generate and publish code artifacts

---

## 6. Development and Testing Strategy

### 6.1 Incremental Development Approach

#### Phase 1: Core Functionality (Weeks 1-2)
**Development Tasks:**
1. Create basic package structure with minimal Nix configuration
2. Implement core protoc wrapper for a single language (Go)
3. Create simple init script to set up directory structure
4. Build basic debug functionality

**Testing Strategy:**
1. **Unit Testing:**
   - Create a simple test proto file with basic definitions
   - Verify correct protoc command generation
   - Test directory structure creation

2. **Integration Testing:**
   - Build a simple service definition
   - Generate code and compile it
   - Verify correct output structure

#### Phase 2: Multi-Language Support and Buf Integration (Weeks 3-4)
**Development Tasks:**
1. Add Python and Rust support
2. Implement buf linting integration
3. Create cache mechanism for generated files
4. Enhance debug output with logging

**Testing Strategy:**
1. **Cross-Language Tests:**
   - Define a service with multiple message types
   - Generate code for all supported languages
   - Compile generated code in each language
   - Create simple serialization/deserialization tests

2. **Linting Tests:**
   - Create intentionally non-compliant proto files
   - Verify lint errors are correctly reported
   - Test lint configuration options

#### Phase 3: Performance Optimizations and Documentation (Weeks 5-6)
**Development Tasks:**
1. Implement incremental generation
2. Add performance benchmarking
3. Create documentation generation
4. Enhance error handling

**Testing Strategy:**
1. **Performance Tests:**
   - Create large proto file sets
   - Measure generation time with and without caching
   - Benchmark incremental vs. full generation
   - Test memory usage under load

2. **Documentation Tests:**
   - Generate documentation in all supported formats
   - Verify accuracy of documentation
   - Test edge cases (empty services, complex nested types)

#### Phase 4: CI/CD and Testing Framework (Weeks 7-8)
**Development Tasks:**
1. Implement CI/CD workflow generation
2. Create testing framework for generated code
3. Add security audit functionality
4. Implement advanced caching mechanisms

**Testing Strategy:**
1. **CI Pipeline Tests:**
   - Test generated workflows on different platforms
   - Verify correct execution of linting and generation
   - Test handling of breaking changes

2. **End-to-End Tests:**
   - Create mock services
   - Generate client and server code
   - Test full communication cycle
   - Verify compatibility between languages

### 6.2 Test Suite Structure
```
/tests
  /unit                    # Unit tests for individual components
    /protoc                # Tests for protoc wrapper
    /buf                   # Tests for buf integration
    /cache                 # Tests for caching mechanisms
    /docs                  # Tests for documentation generation
  
  /integration             # Integration tests for combined functionality
    /languages             # Tests for language support
      /go                  # Go-specific tests
      /python              # Python-specific tests
      /rust                # Rust-specific tests
      /cross               # Cross-language tests
    
    /workflows             # Tests for complete workflows
      /generate            # Code generation workflows
      /lint                # Linting workflows
      /breaking            # Breaking change detection
  
  /performance             # Performance benchmarks
    /large-proto           # Tests with large proto sets
    /incremental           # Tests for incremental generation
    /caching               # Tests for caching efficiency
  
  /fixtures                # Test data
    /protos                # Proto files for testing
    /expected-output       # Expected generation results
    /broken-protos         # Intentionally broken protos for error testing
  
  /scripts                 # Test runner scripts
    /run-unit-tests.sh     # Script to run all unit tests
    /run-integration.sh    # Script to run integration tests
    /run-benchmarks.sh     # Script to run performance tests
    /run-all.sh            # Script to run all tests
```

### 6.3 Development Milestones

| Week | Component                  | Success Criteria                                    |
|------|----------------------------|-----------------------------------------------------|
| 1    | Basic package structure    | Package can be imported in flake.nix                |
| 1    | Protoc Go wrapper          | Go code generation works for simple protos          |
| 2    | Directory initialization   | Running init creates expected directory structure   |
| 2    | Basic debugging            | Debug mode shows detailed command execution         |
| 3    | Python support             | Python code generation works for simple protos      |
| 3    | Rust support               | Rust code generation works for simple protos        |
| 4    | Buf linting                | Linting correctly identifies proto issues           |
| 4    | Basic caching              | Cache correctly stores and retrieves generated code |
| 5    | Incremental generation     | Only changed files are regenerated                  |
| 5    | Performance benchmarking   | Benchmark provides accurate performance metrics     |
| 6    | Documentation generation   | Generated docs correctly represent proto structure  |
| 6    | Enhanced error handling    | Error messages provide clear resolution steps       |
| 7    | CI/CD workflow generation  | Generated workflows run correctly in CI systems     |
| 7    | Testing framework          | Tests can validate generated code functionality     |
| 8    | Security audit             | Audit correctly identifies security concerns        |
| 8    | Advanced caching           | Cache optimally handles complex dependencies        |

---

## 7. Migration Guides

### 7.1 From Protoc to Bufrnix

```markdown
# Migrating from Manual Protoc to Bufrnix

## Step 1: Set up flake.nix
Add bufrnix as an input to your flake.nix

## Step 2: Convert protoc commands
Old:
```
protoc -I=./proto -I=./third_party/proto \
  --go_out=./gen/go --go_opt=paths=source_relative \
  --go-grpc_out=./gen/go --go-grpc_opt=paths=source_relative \
  --python_out=./gen/python --grpc_python_out=./gen/python \
  ./proto/service/v1/*.proto
```

New:
```
bufrnix_generate
```

## Step 3: Create project configuration
Run bufrnix_init to initialize project structure

## Step 4: Adapt your workflow
Replace Makefile targets with bufrnix commands

## Step 5: Test your setup
Run bufrnix_doctor to validate your environment
```

### 7.2 From Buf CLI Generate to Bufrnix

```markdown
# Migrating from Buf CLI Generate to Bufrnix

## Step 1: Set up flake.nix
Add bufrnix as an input to your flake.nix

## Step 2: Convert buf.gen.yaml to Nix config
Old (buf.gen.yaml):
```yaml
version: v1
plugins:
  - name: go
    out: gen/go
    opt: paths=source_relative
  - name: go-grpc
    out: gen/go
    opt: paths=source_relative
```

New (flake.nix):
```nix
languages = {
  go = {
    enable = true;
    outputPath = "gen/go";
    options = [ "paths=source_relative" ];
    grpc.enable = true;
  };
};
```

## Step 3: Keep buf.yaml for linting
Bufrnix uses buf only for linting and breaking change detection

## Step 4: Replace commands
buf generate → bufrnix_generate
buf lint → bufrnix_lint
buf breaking → bufrnix_breaking

## Step 5: Test your setup
Run bufrnix_doctor to validate your environment
```

---

## 8. Roadmap

| Milestone | Description | Timeline |
|-----------|-------------|----------|
| v0.1 (MVP) | Basic standalone package with protoc and language support for Go, Python | 2 weeks |
| v0.2 | Add Rust support, debug mode, caching mechanism | 4 weeks |
| v0.3 | Add testing framework, incremental generation | 6 weeks |
| v0.4 | Add documentation generation, security features | 8 weeks |
| v0.5 | Add CI/CD integration, performance benchmarks | 10 weeks |
| v0.6 | Beta testing, bug fixes, documentation | 12 weeks |
| v1.0 | Stable release with all features | 14 weeks |

---

## 9. Conclusion

The Bufrnix package provides a comprehensive, Nix-powered solution for Protobuf development that uses protoc for code generation while leveraging Buf CLI for linting. By implementing this blueprint, teams can achieve consistent, reproducible Protobuf workflows across development and CI environments without being tied to specific development workflows. 

The clear separation between code generation (via protoc) and linting (via buf) provides the best of both worlds while maintaining a clean, declarative configuration in Nix. The incremental development and testing strategy outlined in this blueprint ensures that each component is thoroughly validated before proceeding to the next phase, reducing integration risks and providing a solid foundation for this critical developer tool.
