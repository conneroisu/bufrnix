---
title: Configuration Reference
description: Complete reference for all Bufrnix configuration options and settings with examples.
---

# Configuration Reference

This page documents all available configuration options for Bufrnix. These options should be set in your project's `flake.nix` file within the `config` attribute of `bufrnix.lib.mkBufrnixPackage`.

## Design Philosophy

Bufrnix configuration prioritizes **explicitness over magic** and **reproducibility over convenience**. Every option is designed to give you complete control while maintaining declarative simplicity:

- **Type-safe**: All options are validated at evaluation time, catching errors before generation runs
- **Reproducible**: Same configuration = identical outputs across all environments and team members
- **Explicit dependencies**: No hidden network calls or surprise downloads - everything declared upfront
- **Modular**: Enable only what you need, compose complex workflows from simple parts

This approach trades some initial setup time for long-term reliability, making Bufrnix ideal for production systems where consistency matters more than convenience.

## Basic Configuration Structure

```nix
bufrnix.lib.mkBufrnixPackage {
  inherit (pkgs) lib pkgs;
  config = {
    # Root configuration
    root = "./proto";

    # Protocol buffer compilation settings
    protoc = { ... };

    # Debug settings
    debug = { ... };

    # Language-specific configurations
    languages = {
      go = { ... };
      dart = { ... };
      js = { ... };
      php = { ... };
      python = { ... };
      swift = { ... };
      csharp = { ... };
      kotlin = { ... };
      cpp = { ... };
      c = { ... };
      doc = { ... };
      svg = { ... };
    };
  };
}
```

## Root Configuration

### Basic Options

| Option | Type   | Default     | Description                    |
| ------ | ------ | ----------- | ------------------------------ |
| `root` | string | `"./proto"` | Root directory for proto files |

### Debug Configuration

```nix
debug = {
  enable = true;         # Enable debug mode
  verbosity = 2;         # Debug verbosity level (1-3)
  logFile = "debug.log"; # Path to debug log file (empty = stdout)
};
```

| Option            | Type    | Default | Description                                        |
| ----------------- | ------- | ------- | -------------------------------------------------- |
| `debug.enable`    | boolean | `false` | Enable debug mode with verbose output              |
| `debug.verbosity` | integer | `1`     | Debug verbosity level (1-3, higher = more verbose) |
| `debug.logFile`   | string  | `""`    | Path to debug log file. If empty, logs to stdout   |

### Protoc Configuration

```nix
protoc = {
  sourceDirectories = ["./proto"];           # Directories containing proto files
  includeDirectories = [                     # Include path directories
    "./proto"
    "${pkgs.protobuf}/include"              # Well-known types
  ];
  files = [                                  # Specific files to compile
    "./proto/user/v1/user.proto"
    "./proto/product/v1/product.proto"
  ];
};
```

| Option                      | Type            | Default       | Description                                                                                     |
| --------------------------- | --------------- | ------------- | ----------------------------------------------------------------------------------------------- |
| `protoc.sourceDirectories`  | list of strings | `["./proto"]` | Directories containing proto files to compile                                                   |
| `protoc.includeDirectories` | list of strings | `["./proto"]` | Directories to include in the include path for imports                                          |
| `protoc.files`              | list of strings | `[]`          | Specific proto files to compile (leave empty to compile all .proto files in source directories) |

## Language Support

### Go Language Configuration

Go support includes the core protobuf compiler plus extensive plugin ecosystem for gRPC, HTTP gateways, validation, and modern RPC frameworks.

```nix
languages.go = {
  enable = true;
  outputPath = "gen/go";
  packagePrefix = "github.com/myorg/myproject";
  options = ["paths=source_relative"];

  # Core gRPC support
  grpc = {
    enable = true;
    options = ["paths=source_relative"];
  };

  # HTTP/JSON gateway
  gateway = {
    enable = true;
    options = ["paths=source_relative" "generate_unbound_methods=true"];
  };

  # Message validation (legacy)
  validate = {
    enable = true;
    options = ["lang=go"];
  };

  # Modern validation with CEL expressions
  protovalidate = {
    enable = true;
  };

  # Modern Connect protocol
  connect = {
    enable = true;
    options = ["paths=source_relative"];
  };

  # OpenAPI v2 documentation
  openapiv2 = {
    enable = true;
    options = ["logtostderr=true"];
  };

  # High-performance serialization (3.8x faster)
  vtprotobuf = {
    enable = true;
    options = ["paths=source_relative" "features=marshal+unmarshal+size"];
  };

  # JSON integration with encoding/json
  json = {
    enable = true;
    options = ["paths=source_relative" "orig_name=true"];
  };

  # gRPC Federation for BFF servers (experimental)
  federation = {
    enable = true;
    options = ["paths=source_relative"];
  };
};
```

#### Go Configuration Options

| Option          | Type            | Default                     | Description                            |
| --------------- | --------------- | --------------------------- | -------------------------------------- |
| `enable`        | boolean         | `false`                     | Enable Go code generation              |
| `outputPath`    | string          | `"gen/go"`                  | Output directory for generated Go code |
| `packagePrefix` | string          | `""`                        | Go package prefix for generated code   |
| `options`       | list of strings | `["paths=source_relative"]` | Options to pass to protoc-gen-go       |

#### Go Plugin Options

Each Go plugin (grpc, gateway, validate, etc.) supports:

- `enable`: Boolean to enable the plugin
- `options`: List of strings for plugin-specific options
- `package`: Nix package to use (usually auto-detected)

### JavaScript/TypeScript Configuration

Modern JavaScript/TypeScript support with multiple output formats and RPC frameworks.

```nix
languages.js = {
  enable = true;
  outputPath = "src/proto";
  packageName = "@myorg/proto";

  # Modern ECMAScript modules with TypeScript (recommended)
  es = {
    enable = true;
    target = "ts";                    # Generate TypeScript
    options = ["import_extension=.js"]; # ES module extensions
    generatePackageJson = true;
    packageName = "@myorg/proto-es";
  };

  # Connect-ES for modern RPC
  connect = {
    enable = true;
    generatePackageJson = true;
    packageName = "@myorg/proto-connect";
  };

  # gRPC-Web for browser compatibility
  grpcWeb = {
    enable = true;
    options = ["import_style=typescript" "mode=grpcwebtext"];
  };

  # Twirp RPC framework
  twirp = {
    enable = true;
  };

  # Modern validation
  protovalidate = {
    enable = true;
    target = "ts";
    generateValidationHelpers = true;
  };

  # ts-proto for idiomatic TypeScript
  tsProto = {
    enable = true;
    options = ["esModuleInterop=true" "useOptionals=messages"];
    generatePackageJson = true;
    generateTsConfig = true;
  };
};
```

#### JavaScript Configuration Options

| Option        | Type            | Default    | Description                                  |
| ------------- | --------------- | ---------- | -------------------------------------------- |
| `enable`      | boolean         | `false`    | Enable JavaScript/TypeScript code generation |
| `outputPath`  | string          | `"gen/js"` | Output directory for generated code          |
| `packageName` | string          | `""`       | JavaScript package name                      |
| `options`     | list of strings | `[]`       | Options to pass to protoc JS plugins         |

### Dart Configuration

Dart support for Flutter and server applications with full gRPC support.

```nix
languages.dart = {
  enable = true;
  outputPath = "lib/proto";
  packageName = "my_app_proto";

  grpc = {
    enable = true;
  };
};
```

| Option        | Type    | Default       | Description                              |
| ------------- | ------- | ------------- | ---------------------------------------- |
| `enable`      | boolean | `false`       | Enable Dart code generation              |
| `outputPath`  | string  | `"lib/proto"` | Output directory for generated Dart code |
| `packageName` | string  | `""`          | Dart package name for generated code     |

### PHP Configuration

Comprehensive PHP support with multiple frameworks and async patterns.

```nix
languages.php = {
  enable = true;
  outputPath = "gen/php";
  namespace = "MyApp\\Proto";
  metadataNamespace = "GPBMetadata";
  classPrefix = "";

  # Composer integration
  composer = {
    enable = true;
    autoInstall = false;
  };

  # gRPC support
  grpc = {
    enable = true;
    clientOnly = false;
    serviceNamespace = "Services";
  };

  # RoadRunner for high-performance gRPC servers
  roadrunner = {
    enable = true;
    workers = 4;
    maxJobs = 64;
    maxMemory = 128; # MB
    tlsEnabled = false;
  };

  # Framework integrations
  frameworks = {
    laravel = {
      enable = true;
      serviceProvider = true;
      artisanCommands = true;
    };

    symfony = {
      enable = true;
      bundle = true;
      messengerIntegration = true;
    };
  };

  # Async PHP patterns
  async = {
    reactphp = {
      enable = true;
      version = "^1.0";
    };

    swoole = {
      enable = true;
      coroutines = true;
    };

    fibers = {
      enable = true; # PHP 8.1+ Fiber support
    };
  };

  # Legacy Twirp support (deprecated)
  twirp = {
    enable = false; # Use gRPC instead
  };
};
```

### Python Configuration

Python support with multiple generation styles and async support.

```nix
languages.python = {
  enable = true;
  outputPath = "gen/python";

  # gRPC support
  grpc = {
    enable = true;
  };

  # Type stubs for mypy
  pyi = {
    enable = true;
  };

  # Modern dataclasses with betterproto
  betterproto = {
    enable = true;
  };

  # mypy stub generation
  mypy = {
    enable = true;
  };
};
```

### Swift Configuration

Swift support for iOS, macOS, and server applications.

```nix
languages.swift = {
  enable = true;
  outputPath = "Sources/Generated";
  packageName = "MyAppProto";
};
```

### C# Configuration

Comprehensive C# support with .NET project generation and NuGet integration.

```nix
languages.csharp = {
  enable = true;
  outputPath = "gen/csharp";
  namespace = "MyApp.Proto";
  targetFramework = "net8.0";
  langVersion = "latest";
  nullable = true;

  # Project file generation
  generateProjectFile = true;
  projectName = "MyApp.Proto";
  packageId = "MyApp.Proto";
  packageVersion = "1.0.0";
  generatePackageOnBuild = false;

  # Assembly configuration
  generateAssemblyInfo = true;
  assemblyVersion = "1.0.0.0";
  protobufVersion = "3.31.0";

  # gRPC support
  grpc = {
    enable = true;
    grpcVersion = "2.72.0";
    grpcCoreVersion = "2.72.0";
    generateClientFactory = true;
    generateServerBase = true;
  };
};
```

### Kotlin Configuration

Kotlin support with Java interop and modern coroutine-based gRPC.

```nix
languages.kotlin = {
  enable = true;
  outputPath = "gen/kotlin";
  javaOutputPath = "gen/kotlin/java";    # Required for Kotlin
  kotlinOutputPath = "gen/kotlin/kotlin";

  # Project configuration
  projectName = "MyProtos";
  kotlinVersion = "2.1.20";
  protobufVersion = "4.28.2";
  jvmTarget = 17;
  coroutinesVersion = "1.8.0";

  generateBuildFile = true;
  generatePackageInfo = false;

  # gRPC with coroutines
  grpc = {
    enable = true;
    grpcVersion = "1.62.2";
    grpcKotlinVersion = "1.4.2";
    generateServiceImpl = false;
  };

  # Connect RPC
  connect = {
    enable = true;
    connectVersion = "0.7.3";
    packageName = "com.example.connect";
    generateClientConfig = true;
  };
};
```

### C++ Configuration

Advanced C++ support with multiple standards and optimization options.

```nix
languages.cpp = {
  enable = true;
  outputPath = "gen/cpp";
  protobufVersion = "latest";
  standard = "c++20";
  optimizeFor = "SPEED";  # SPEED, CODE_SIZE, LITE_RUNTIME
  runtime = "full";       # full or lite

  # Build system integration
  cmakeIntegration = true;
  pkgConfigIntegration = true;

  # Performance options
  arenaAllocation = true;

  # Additional include paths
  includePaths = ["/usr/local/include"];

  # gRPC support
  grpc = {
    enable = true;
    generateMockCode = true;
  };

  # Embedded systems with nanopb
  nanopb = {
    enable = true;
    options = ["max_size=1024" "max_count=16"];
  };

  # Pure C with protobuf-c
  protobuf-c = {
    enable = true;
  };
};
```

### C Configuration

Pure C support for embedded and system programming.

```nix
languages.c = {
  enable = true;
  outputPath = "gen/c";

  # Standard C implementation
  protobuf-c = {
    enable = true;
    outputPath = "gen/c/protobuf-c";
  };

  # Embedded/lightweight implementation
  nanopb = {
    enable = true;
    outputPath = "gen/c/nanopb";
    maxSize = 1024;
    fixedLength = false;
    noUnions = false;
    msgidType = "";
  };

  # Future: Google's upb (not yet available)
  upb = {
    enable = false;
    outputPath = "gen/c/upb";
  };
};
```

### Documentation Configuration

Generate documentation from your proto files.

```nix
languages.doc = {
  enable = true;
  outputPath = "gen/doc";
  format = "html";        # html, markdown, json, docbook
  outputFile = "index.html";
  options = ["html,index.html"];
};
```

### SVG Diagram Configuration

Generate visual diagrams of your proto structure.

```nix
languages.svg = {
  enable = true;
  outputPath = "gen/svg";
};
```

## Complete Multi-Language Example

Here's a comprehensive example showing multiple languages configured together:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, bufrnix, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.default = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib pkgs;
      config = {
        root = ./.;

        # Enhanced debugging
        debug = {
          enable = true;
          verbosity = 2;
          logFile = "bufrnix-debug.log";
        };

        protoc = {
          sourceDirectories = ["./proto"];
          includeDirectories = [
            "./proto"
            "${pkgs.protobuf}/include"
            "${pkgs.googleapis-common-protos}/share/googleapis-common-protos"
          ];
          files = [
            "./proto/user/v1/user.proto"
            "./proto/product/v1/product.proto"
            "./proto/order/v1/order.proto"
          ];
        };

        languages = {
          # Backend: Go with full ecosystem
          go = {
            enable = true;
            outputPath = "gen/go";
            packagePrefix = "github.com/myorg/myproject";
            options = ["paths=source_relative"];

            grpc.enable = true;
            gateway.enable = true;
            connect.enable = true;
            protovalidate.enable = true;
            vtprotobuf.enable = true; # High performance
            json.enable = true;
            openapiv2.enable = true;
          };

          # Frontend: TypeScript with modern tooling
          js = {
            enable = true;
            outputPath = "web/src/proto";
            packageName = "@myorg/proto";

            es = {
              enable = true;
              target = "ts";
              generatePackageJson = true;
            };

            connect.enable = true;
            grpcWeb.enable = true;
            protovalidate.enable = true;
          };

          # Mobile: Dart for Flutter
          dart = {
            enable = true;
            outputPath = "mobile/lib/proto";
            packageName = "myorg_proto";
            grpc.enable = true;
          };

          # Additional services: PHP
          php = {
            enable = true;
            outputPath = "services/php/gen";
            namespace = "MyOrg\\Proto";

            grpc.enable = true;
            roadrunner.enable = true;

            frameworks.laravel.enable = true;
            async.swoole.enable = true;
          };

          # Mobile: Swift for iOS
          swift = {
            enable = true;
            outputPath = "ios/Sources/Proto";
            packageName = "MyOrgProto";
          };

          # Enterprise: C# for .NET services
          csharp = {
            enable = true;
            outputPath = "dotnet/src/Proto";
            namespace = "MyOrg.Proto";
            targetFramework = "net8.0";

            grpc.enable = true;
            generateProjectFile = true;
            projectName = "MyOrg.Proto";
          };

          # Documentation and diagrams
          doc = {
            enable = true;
            outputPath = "docs/proto";
            format = "html";
            outputFile = "api-docs.html";
          };

          svg = {
            enable = true;
            outputPath = "docs/diagrams";
          };
        };
      };
    };

    # Development shell with all language runtimes
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        go dart nodejs php83 swift dotnet-sdk_8
        protobuf buf grpcurl protoc-gen-doc
      ];

      shellHook = ''
        echo "🚀 Multi-language protobuf development environment ready!"
        echo ""
        echo "Available commands:"
        echo "  nix build                 - Generate all protobuf code"
        echo "  buf lint                  - Lint proto files"
        echo "  buf format --write        - Format proto files"
        echo "  grpcurl                   - Test gRPC services"
        echo ""
        echo "Language runtimes available:"
        echo "  go version: $(go version)"
        echo "  dart version: $(dart --version)"
        echo "  node version: $(node --version)"
        echo "  php version: $(php --version | head -1)"
        echo "  dotnet version: $(dotnet --version)"
      '';
    };
  };
}
```

## Advanced Configuration Patterns

### Environment-Specific Builds

Generate different configurations for different environments:

```nix
{
  packages = {
    # Development build with all debugging enabled
    dev = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib pkgs;
      config = {
        debug.enable = true;
        debug.verbosity = 3;
        languages.go = {
          enable = true;
          validate.enable = true;
          gateway.enable = true;
          openapiv2.enable = true;
        };
      };
    };

    # Production build optimized for performance
    prod = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib pkgs;
      config = {
        languages.go = {
          enable = true;
          vtprotobuf.enable = true; # High performance
          options = ["paths=source_relative"];
        };
      };
    };

    # Client-only build for frontend
    client = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib pkgs;
      config = {
        languages.js = {
          enable = true;
          es.enable = true;
          connect.enable = true;
          grpcWeb.enable = true;
        };
      };
    };
  };
}
```

### Microservices Architecture

Configure different services with different language requirements:

```nix
{
  packages = {
    user-service = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib pkgs;
      config = {
        protoc.files = ["./proto/user/v1/user.proto"];
        languages.go = {
          enable = true;
          outputPath = "services/user/proto";
          grpc.enable = true;
          protovalidate.enable = true;
        };
      };
    };

    payment-service = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib pkgs;
      config = {
        protoc.files = ["./proto/payment/v1/payment.proto"];
        languages.go = {
          enable = true;
          outputPath = "services/payment/proto";
          grpc.enable = true;
          vtprotobuf.enable = true; # High performance for payments
        };
      };
    };

    web-gateway = bufrnix.lib.mkBufrnixPackage {
      inherit (pkgs) lib pkgs;
      config = {
        protoc.files = [
          "./proto/user/v1/user.proto"
          "./proto/payment/v1/payment.proto"
        ];
        languages.go = {
          enable = true;
          outputPath = "gateway/proto";
          grpc.enable = true;
          gateway.enable = true; # HTTP/JSON gateway
        };
        
        # API documentation
        openapi = {
          enable = true;
          outputPath = "gateway/openapi";
        };
      };
    };
  };
}
```

### Performance Optimization

Configure for maximum performance:

```nix
languages.go = {
  enable = true;

  # Use vtprotobuf for 3.8x faster serialization
  vtprotobuf = {
    enable = true;
    options = [
      "paths=source_relative"
      "features=marshal+unmarshal+size+pool" # Enable all optimizations
    ];
  };

  # Optimize protoc options
  options = [
    "paths=source_relative"
    "Mgrpc/service_config/service_config.proto=google.golang.org/grpc/serviceconfig"
  ];
};

languages.cpp = {
  enable = true;
  standard = "c++20";
  optimizeFor = "SPEED";
  runtime = "lite";        # Smaller runtime for performance
  arenaAllocation = true;  # Better memory performance
};
```

## Troubleshooting Configuration

### Debug Configuration Issues

Enable comprehensive debugging to troubleshoot configuration problems:

```nix
config = {
  debug = {
    enable = true;
    verbosity = 3;           # Maximum verbosity
    logFile = "debug.log";   # Save to file for analysis
  };

  # Your other configuration...
};
```

### Common Configuration Errors

1. **Missing include directories**: Add protobuf well-known types

   ```nix
   protoc.includeDirectories = [
     "./proto"
     "${pkgs.protobuf}/include"
   ];
   ```

2. **Package import issues**: Ensure correct package prefixes

   ```nix
   languages.go.packagePrefix = "github.com/yourorg/yourproject";
   ```

3. **Output path conflicts**: Use different output paths for each language
   ```nix
   languages.go.outputPath = "gen/go";
   languages.js.outputPath = "gen/js";
   ```

For more troubleshooting help, see the [Troubleshooting Guide](/guides/troubleshooting/).

## Migration from Previous Versions

When upgrading Bufrnix, you may need to update your configuration:

1. **URL Changes**: Update from `github:conneroisu/bufr.nix` to `github:conneroisu/bufrnix`
2. **API Changes**: Replace `bufrnix generate` with `nix build`
3. **New Options**: Review new language options and plugins
4. **Deprecated Features**: Check for deprecated options in your configuration

See the [Migration Guide](/guides/migration/) for detailed upgrade instructions.
