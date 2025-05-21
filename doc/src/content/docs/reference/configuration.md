---
title: Configuration Reference
description: Complete reference for Bufrnix configuration options and settings.
---

# Configuration Reference

This page documents all available configuration options for Bufrnix. These options should be set in your project's `flake.nix` file within the `bufrnix` attribute.

## Basic Configuration

The top-level configuration attributes:

```nix
{
  bufrnix = {
    # The root directory containing your proto files
    root = "./proto";
    
    # Language-specific configurations
    go = { ... };
    dart = { ... };
    js = { ... };
    php = { ... };
    
    # Additional options
    buftools = { ... };
    linting = { ... };
  };
}
```

## Common Options

These options are available for all language generators:

| Option | Description | Default |
| ------ | ----------- | ------- |
| `enable` | Enable code generation for this language | `false` |
| `out` | Output directory relative to the proto root | Varies by language |
| `opt` | Additional options to pass to the protoc plugin | `{}` |

## Go Configuration

Configure Protocol Buffer code generation for Go:

```nix
go = {
  enable = true;
  out = "gen/go";
  
  # Standard protoc-gen-go options
  opt = {
    "paths=source_relative" = null;
    "M*=example.com/project/gen/go" = null;
  };
  
  # Enable gRPC
  grpc = {
    enable = true;
    opt = { ... };
  };
  
  # Enable Connect
  connect = {
    enable = true;
    opt = { ... };
  };
  
  # Enable gRPC-Gateway
  gateway = {
    enable = true;
    opt = { ... };
  };
  
  # Enable validation
  validate = {
    enable = true;
    opt = { ... };
  };
};
```

## Dart Configuration

Configure Protocol Buffer code generation for Dart:

```nix
dart = {
  enable = true;
  out = "gen/dart";
  
  # Standard protoc-gen-dart options
  opt = {
    "grpc" = null;
  };
  
  # Enable gRPC
  grpc = {
    enable = true;
    opt = { ... };
  };
};
```

## JavaScript/TypeScript Configuration

Configure Protocol Buffer code generation for JavaScript and TypeScript:

```nix
js = {
  enable = true;
  out = "gen/js";
  
  # Standard protoc-gen-js options
  opt = {
    "import_style=commonjs" = null;
    "binary" = null;
  };
  
  # Enable gRPC-Web
  grpcWeb = {
    enable = true;
    mode = "grpcwebtext"; # or "grpcweb"
    opt = { ... };
  };
  
  # Enable Twirp
  twirp = {
    enable = true;
    opt = { ... };
  };
};
```

## PHP Configuration

Configure Protocol Buffer code generation for PHP:

```nix
php = {
  enable = true;
  out = "gen/php";
  
  # Standard protoc-gen-php options
  opt = { ... };
  
  # Enable Twirp
  twirp = {
    enable = true;
    opt = { ... };
  };
};
```

## Buf Tools Configuration

Configure integration with buf.build tools:

```nix
buftools = {
  enable = true;
  
  # Configure linting
  lint = {
    enable = true;
    configPath = "./buf.yaml";
  };
  
  # Configure breaking change detection
  breaking = {
    enable = true;
    against = "https://github.com/username/repo.git#branch=main,ref=HEAD~1";
  };
};
```

## Advanced Options

### Custom Plugins

You can add custom protoc plugins:

```nix
customPlugins = {
  "protoc-gen-custom" = {
    package = pkgs.protoc-gen-custom;
    out = "gen/custom";
    opt = {
      "custom-option" = null;
    };
  };
};
```

### Environment Variables

Set environment variables for code generation:

```nix
env = {
  CUSTOM_ENV_VAR = "value";
};
```

### Pre/Post Hooks

Add custom hooks before or after code generation:

```nix
hooks = {
  pre = ''
    echo "Running before code generation"
    # Additional shell commands
  '';
  
  post = ''
    echo "Running after code generation"
    # Additional shell commands
  '';
};
```

## Full Example

Here's a comprehensive example with multiple languages:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, bufrnix, ... }: {
    bufrnix = {
      root = "./proto";
      
      # Go configuration
      go = {
        enable = true;
        out = "gen/go";
        opt = {
          "paths=source_relative" = null;
        };
        
        grpc.enable = true;
        connect.enable = true;
      };
      
      # JavaScript configuration
      js = {
        enable = true;
        out = "gen/js";
        
        grpcWeb = {
          enable = true;
          mode = "grpcwebtext";
        };
      };
      
      # Dart configuration
      dart = {
        enable = true;
        out = "gen/dart";
        
        grpc.enable = true;
      };
      
      # Custom hooks
      hooks = {
        post = ''
          echo "Generated code for all languages"
        '';
      };
    };
  };
}
```