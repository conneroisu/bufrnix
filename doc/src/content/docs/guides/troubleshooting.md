---
title: Troubleshooting Guide
description: Common issues and solutions when using Bufrnix for Protocol Buffer code generation.
---

# Troubleshooting Guide

This guide covers common issues you might encounter when using Bufrnix and provides practical solutions to resolve them.

## Getting Help

If you can't find a solution here:

1. Check the [examples directory](https://github.com/conneroisu/bufrnix/tree/main/examples) for similar use cases
2. Enable debug mode for detailed error information
3. Search existing [GitHub issues](https://github.com/conneroisu/bufrnix/issues)
4. Create a new issue with your configuration and error details

## Debug Mode

Enable debug mode to get detailed information about what Bufrnix is doing:

```nix
config = {
  debug = {
    enable = true;
    verbosity = 3;           # 1-3, higher = more verbose
    logFile = "debug.log";   # Save to file for analysis
  };

  # Your other configuration...
};
```

## Common Issues

### Build and Generation Issues

#### Error: Proto file not found

**Error Message:**

```
error: proto file not found: ./proto/example/v1/example.proto
```

**Causes and Solutions:**

1. **File doesn't exist**: Verify the file exists at the specified path

   ```bash
   ls -la proto/example/v1/example.proto
   ```

2. **Incorrect path**: Check the path in your configuration

   ```nix
   protoc.files = [
     "./proto/example/v1/example.proto"  # Relative to config.root
   ];
   ```

3. **Wrong root directory**: Ensure `root` points to the correct directory
   ```nix
   config = {
     root = ./.; # Should point to directory containing proto/
   };
   ```

#### Error: Import not found

**Error Message:**

```
Import "google/protobuf/timestamp.proto" was not found
```

**Solution:** Add well-known types to include directories

```nix
protoc.includeDirectories = [
  "./proto"
  "${pkgs.protobuf}/include"                    # Well-known types
  "${pkgs.googleapis-common-protos}/share/googleapis-common-protos"  # Google APIs
];
```

#### Error: Package import issues in Go

**Error Message:**

```
package github.com/yourorg/yourproject/gen/go/example/v1 is not in GOROOT or GOPATH
```

**Solutions:**

1. **Check go_package option in proto file:**

   ```protobuf
   option go_package = "github.com/yourorg/yourproject/gen/go/example/v1;examplev1";
   ```

2. **Ensure generated code is in Go module:**

   ```bash
   go mod tidy
   ```

3. **Verify Go module path matches generated code:**
   ```bash
   # Check go.mod file
   module github.com/yourorg/yourproject
   ```

#### Error: Nix build failures

**Error Message:**

```
error: builder for '/nix/store/...' failed with exit code 1
```

**Troubleshooting steps:**

1. **Enable debug mode** for detailed logs:

   ```nix
   debug = {
     enable = true;
     verbosity = 3;
   };
   ```

2. **Check build dependencies** are available:

   ```bash
   nix-shell -p protobuf protoc-gen-go
   ```

3. **Verify system architecture** matches configuration:

   ```nix
   let
     system = builtins.currentSystem; # Use this instead of hardcoding
   ```

4. **Clear Nix cache** if persistent issues:
   ```bash
   nix-collect-garbage
   nix build --no-cache
   ```

### Language-Specific Issues

#### Go Issues

**Error: Undefined gRPC methods**

```
undefined: examplev1.UnimplementedGreetingServiceServer
```

**Solution:** Ensure gRPC generation is enabled

```nix
languages.go = {
  enable = true;
  grpc.enable = true;  # This was missing
};
```

**Error: Validation functions not found**

```
undefined: req.Validate
```

**Solution:** Enable validation plugin

```nix
languages.go = {
  enable = true;
  validate.enable = true;      # Legacy validation
  # OR
  protovalidate.enable = true; # Modern validation
};
```

#### JavaScript/TypeScript Issues

**Error: Module not found**

```
Cannot find module '@myorg/proto'
```

**Solutions:**

1. **Check package.json generation:**

   ```nix
   languages.js = {
     enable = true;
     es = {
       enable = true;
       generatePackageJson = true;
       packageName = "@myorg/proto";
     };
   };
   ```

2. **Install generated packages:**
   ```bash
   npm install ./gen/js  # If package.json was generated
   ```

**Error: TypeScript type errors**

```
Property 'myField' does not exist on type 'MyMessage'
```

**Solution:** Ensure TypeScript target is enabled

```nix
languages.js = {
  enable = true;
  es = {
    enable = true;
    target = "ts";  # Generate TypeScript
  };
};
```

#### Dart Issues

**Error: Package import issues**

```
Target of URI doesn't exist: 'package:my_app_proto/...'
```

**Solution:** Run `dart pub get` in the project directory

```bash
cd path/to/dart/project
dart pub get
```

#### PHP Issues

**Error: Class not found**

```
Class 'MyApp\Proto\MyMessage' not found
```

**Solutions:**

1. **Check namespace configuration:**

   ```nix
   languages.php = {
     enable = true;
     namespace = "MyApp\\Proto";
   };
   ```

2. **Ensure Composer autoloading:**

   ```json
   {
     "autoload": {
       "psr-4": {
         "MyApp\\Proto\\": "gen/php/"
       }
     }
   }
   ```

3. **Run composer install:**
   ```bash
   composer install
   ```

#### C# Issues

**Error: Package reference issues**

```
The type or namespace name 'Google' could not be found
```

**Solution:** Ensure project file generation is enabled

```nix
languages.csharp = {
  enable = true;
  generateProjectFile = true;
  protobufVersion = "3.31.0";
};
```

Then restore packages:

```bash
dotnet restore gen/csharp/
```

### Performance Issues

#### Slow Code Generation

**Symptoms:**

- `nix build` takes a long time
- Large number of proto files cause timeouts

**Solutions:**

1. **Use specific file lists** instead of globbing:

   ```nix
   protoc.files = [
     "./proto/user/v1/user.proto"
     "./proto/product/v1/product.proto"
   ];
   # Instead of: ["./proto/**/*.proto"]
   ```

2. **Enable parallel builds:**

   ```bash
   # Add to ~/.config/nix/nix.conf
   max-jobs = auto
   ```

3. **Use binary caches:**
   ```bash
   # Add to ~/.config/nix/nix.conf
   substituters = https://cache.nixos.org https://nix-community.cachix.org
   trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
   ```

#### Large Generated Code Size

**Symptoms:**

- Generated code is much larger than expected
- Build artifacts are consuming too much disk space

**Solutions:**

1. **Use lite runtime** for C++:

   ```nix
   languages.cpp = {
     enable = true;
     runtime = "lite";
     optimizeFor = "CODE_SIZE";
   };
   ```

2. **Optimize JavaScript output:**

   ```nix
   languages.js = {
     enable = true;
     es = {
       enable = true;
       target = "js"; # Smaller than TypeScript
     };
   };
   ```

3. **Use vtprotobuf for Go** (smaller and faster):
   ```nix
   languages.go = {
     enable = true;
     vtprotobuf = {
       enable = true;
       options = ["features=marshal+unmarshal+size"];
     };
   };
   ```

### System and Environment Issues

#### Nix Flakes Not Enabled

**Error Message:**

```
error: experimental Nix feature 'flakes' is disabled
```

**Solution:** Enable flakes in Nix configuration

```bash
# For NixOS, add to /etc/nixos/configuration.nix:
nix.settings.experimental-features = [ "nix-command" "flakes" ];

# For non-NixOS systems, add to ~/.config/nix/nix.conf:
experimental-features = nix-command flakes
```

#### Permission Issues

**Error Message:**

```
Permission denied: cannot write to gen/go/
```

**Solutions:**

1. **Check directory permissions:**

   ```bash
   ls -la gen/
   chmod -R u+w gen/
   ```

2. **Ensure output directory is writable:**

   ```bash
   mkdir -p gen/go
   chmod u+w gen/go
   ```

3. **On macOS, check Nix permissions:**
   ```bash
   # Ensure Nix daemon has necessary permissions
   sudo launchctl stop org.nixos.nix-daemon
   sudo launchctl start org.nixos.nix-daemon
   ```

#### macOS ARM64 (Apple Silicon) Support

**Kotlin gRPC on Apple Silicon:**

Bufrnix automatically handles gRPC Java plugin compatibility on Apple Silicon Macs by using Rosetta 2 for x86_64 binaries. If you encounter issues:

1. **Install Rosetta 2** (if not already installed):

   ```bash
   /usr/sbin/softwareupdate --install-rosetta --agree-to-license
   ```

2. **Verify the plugin wrapper is working:**

   ```bash
   nix build .#proto
   ./result/bin/bufrnix
   ```

3. **If you see "Bad CPU type" errors:**
   ```bash
   # Check if Rosetta 2 is properly installed
   /usr/bin/arch -x86_64 /usr/bin/true && echo "Rosetta 2 is working"
   ```

The gRPC Java plugin is automatically wrapped to use Rosetta 2 when running on ARM64 systems, ensuring compatibility without requiring manual intervention.

#### System Architecture Mismatch

**Error Message:**

```
error: a 'x86_64-linux' with features {} is required to build...
```

**Solution:** Use correct system identifier

```nix
let
  system = builtins.currentSystem; # Auto-detect
  # Or specify explicitly:
  # system = "x86_64-darwin";  # macOS Intel
  # system = "aarch64-darwin"; # macOS Apple Silicon
  # system = "x86_64-linux";   # Linux x86_64
  # system = "aarch64-linux";  # Linux ARM64
```

### Configuration Issues

#### Invalid Configuration Options

**Error Message:**

```
error: attribute 'invalidOption' missing
```

**Solution:** Check configuration against the [Configuration Reference](/reference/configuration/)

#### Conflicting Plugin Options

**Error Message:**

```
error: conflicting options for protoc-gen-go
```

**Solution:** Check for conflicting options in different plugins

```nix
languages.go = {
  enable = true;
  options = ["paths=source_relative"];

  grpc = {
    enable = true;
    options = ["paths=source_relative"]; # Consistent with parent
  };
};
```

### Development Environment Issues

#### Missing Language Runtimes

**Error Message:**

```
command not found: go
```

**Solution:** Add language runtimes to development shell

```nix
devShells.default = pkgs.mkShell {
  packages = with pkgs; [
    go
    dart
    nodejs
    php83
    python3
    # Add other runtimes as needed
  ];
};
```

#### IDE Integration Issues

**Problem:** IDE doesn't recognize generated code

**Solutions:**

1. **For VS Code with Go:**

   ```json
   {
     "go.toolsEnvVars": {
       "GOPATH": "${workspaceFolder}/gen/go"
     }
   }
   ```

2. **For IntelliJ with Kotlin:**

   - Mark `gen/kotlin` as source directory
   - Ensure Gradle sync is enabled

3. **For general IDE support:**
   - Ensure generated code is in the IDE's source path
   - Run `nix develop` before starting the IDE

### Testing Issues

#### gRPC Server Connection Issues

**Error Message:**

```
rpc error: code = Unavailable desc = connection error
```

**Solutions:**

1. **Check server is running:**

   ```bash
   netstat -ln | grep :50051
   ```

2. **Test with grpcurl:**

   ```bash
   grpcurl -plaintext localhost:50051 list
   ```

3. **Check firewall settings:**

   ```bash
   # On Linux
   sudo ufw allow 50051

   # On macOS
   sudo pfctl -f /etc/pf.conf
   ```

#### Test File Import Issues

**Error Message:**

```
cannot import name 'user_pb2' from 'proto'
```

**Solution:** Ensure Python path includes generated code

```python
import sys
sys.path.append('gen/python')
import user_pb2
```

## Diagnostic Commands

### Check Nix Environment

```bash
# Check Nix installation
nix --version

# Check flakes are enabled
nix eval --expr 'builtins.currentSystem'

# Check available packages
nix search nixpkgs protobuf
```

### Check Generated Code

```bash
# List generated files
find gen/ -name "*.pb.go" -o -name "*.pb.ts" -o -name "*.pb.dart"

# Check file sizes
du -sh gen/*/

# Verify file contents
head -20 gen/go/example/v1/example.pb.go
```

### Check Proto Files

```bash
# Validate proto syntax
protoc --proto_path=proto --dry_run proto/**/*.proto

# Check imports
grep -r "import" proto/

# Lint with buf (if available)
buf lint
```

### Performance Diagnostics

```bash
# Time the build
time nix build

# Check memory usage
nix build --option build-use-substitutes false --option build-max-jobs 1

# Profile build
nix build --option build-use-substitutes false --show-trace
```

## Advanced Troubleshooting

### Custom Debugging

Create a debug build with maximum verbosity:

```nix
{
  packages.debug = bufrnix.lib.mkBufrnixPackage {
    inherit (pkgs) lib pkgs;
    config = {
      debug = {
        enable = true;
        verbosity = 3;
        logFile = "bufrnix-debug.log";
      };

      # Minimal configuration to isolate issues
      languages.go = {
        enable = true;
        outputPath = "debug/go";
      };
    };
  };
}
```

### Isolating Issues

Test with minimal configuration:

```nix
config = {
  root = ./.;
  protoc.files = ["./proto/simple.proto"]; # Single file
  languages.go = {
    enable = true;
    outputPath = "debug/go";
    # No additional plugins
  };
};
```

### Checking Dependencies

Verify all required packages are available:

```bash
nix-shell -p protobuf protoc-gen-go protoc-gen-go-grpc
protoc --version
protoc-gen-go --version
protoc-gen-go-grpc --version
```

## Reporting Issues

When reporting issues, please include:

1. **Bufrnix version or commit hash**
2. **Complete flake.nix configuration**
3. **Error message and stack trace**
4. **Debug log output** (with debug.verbosity = 3)
5. **System information** (OS, architecture)
6. **Example proto files** that cause the issue

### Minimal Reproduction

Create a minimal example that reproduces the issue:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    bufrnix.url = "github:conneroisu/bufrnix";
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
        debug.enable = true;
        protoc.files = ["./example.proto"];
        languages.go.enable = true;
      };
    };
  };
}
```

With a simple proto file:

```protobuf
syntax = "proto3";
package example;
option go_package = "example.com/test;test";

message TestMessage {
  string text = 1;
}
```

This helps maintainers reproduce and fix issues quickly.

## Prevention

### Best Practices

1. **Start simple**: Begin with basic configuration and add complexity gradually
2. **Use examples**: Base your configuration on working examples
3. **Enable debug mode**: Use debug mode during development
4. **Test incrementally**: Test each language addition separately
5. **Keep configurations consistent**: Use similar patterns across projects

### Regular Maintenance

1. **Update regularly**: Keep Bufrnix and dependencies up to date
2. **Clean builds**: Periodically run `nix-collect-garbage`
3. **Validate proto files**: Use `buf lint` to catch issues early
4. **Monitor performance**: Watch for degradation in build times

By following this guide, you should be able to resolve most issues with Bufrnix. For additional help, don't hesitate to reach out to the community through GitHub issues or discussions.
