# Multiple Configurable Output Paths Specification

## Overview

This specification defines a feature to allow configuration of multiple output paths for language configurations by changing the `outputPath` parameter from a single string to support arrays of strings. This enhancement addresses the need for generating the same protobuf definitions to multiple locations, supporting complex project structures and organizational requirements.

## Current State

Currently, Bufrnix language configurations support a single `outputPath` parameter that determines where all generated code for that language is placed:

```nix
languages = {
  go = {
    enable = true;
    outputPath = "gen/go";  # Single path for all Go code
    grpc.enable = true;
    validate.enable = true;
  };
};
```

This approach has limitations when projects need to generate the same code to multiple directories (e.g., for different modules, services, or distribution packages).

## Proposed Enhancement

### Array-Based Output Paths

Change the `outputPath` type from `types.str` to `types.either types.str (types.listOf types.str)` to support both single paths (backward compatibility) and multiple paths:

```nix
languages = {
  go = {
    enable = true;
    outputPath = [
      "gen/go"
      "internal/proto" 
      "pkg/shared/proto"
    ];
    grpc.enable = true;
    validate.enable = true;
  };
};
```

When `outputPath` is an array, Bufrnix will generate the exact same code to each specified directory.

## Implementation Strategy

### 1. Update Type Definitions

Modify `src/lib/bufrnix-options.nix` to change all `outputPath` option types:

```nix
outputPath = mkOption {
  type = types.either types.str (types.listOf types.str);
  default = "gen/go";  # or appropriate language default
  description = "Output directory(ies) for generated code";
  example = literalExpression ''
    [
      "gen/go"
      "pkg/proto"
      "internal/shared/proto"
    ]
  '';
};
```

### 2. Update Core Generation Logic

Modify `src/lib/mkBufrnix.nix` to handle array-based output paths:

1. **Normalize Output Paths**: Convert single strings to single-element arrays internally
2. **Multiple Generation**: Run protoc generation for each output path
3. **Directory Creation**: Ensure all target directories exist
4. **Error Handling**: Provide clear error messages for invalid paths

### 3. Update Language Modules

Update all language modules in `src/languages/` to handle array-based paths:

```nix
# Example for Go module
let
  outputPaths = if builtins.isList cfg.outputPath 
                then cfg.outputPath 
                else [ cfg.outputPath ];
  
  generateForPath = outputPath: ''
    protoc ${protocArgs} --go_out=${outputPath} ${protoFiles}
  '';
  
  allGenerateCommands = map generateForPath outputPaths;
in
```

## Configuration Examples

### Example 1: Shared Library Generation

```nix
languages = {
  go = {
    enable = true;
    outputPath = [
      "gen/go"                    # Main generated code
      "vendor/proto"              # Vendor directory for dependencies  
      "pkg/shared/proto"          # Shared package location
    ];
    grpc= {
      enable = true;
      outputPath = [
        "gen/go/grpc"              # Generated code for gRPC
        "vendor/proto/grpc"        # Vendor directory for gRPC dependencies
      ];
    };
  };
};
```

### Example 2: Multi-Module Project

The following example shows how to generate the same code to multiple directories for js:
```nix
languages = {
  js = {
    enable = true;
    outputPath = [
      "packages/frontend/src/proto" 
      "packages/backend/src/proto"
      "packages/shared/proto"
    ];
    es.enable = true;
    connect.enable = true;
  };
};
```

### Example 3: Development and Distribution

```nix
languages = {
  python = {
    enable = true;
    outputPath = [
      "src/proto"                 # Development location
      "dist/mypackage/proto"      # Distribution package
      "tests/fixtures/proto"      # Test fixtures
    ];
    grpc.enable = true;
    pyi.enable = true;
  };
};
```

### Example 4: Microservices Architecture

```nix
languages = {
  go = {
    enable = true;
    outputPath = [
      "services/user/proto"
      "services/order/proto"  
      "services/inventory/proto"
      "pkg/common/proto"
    ];
    grpc.enable = true;
    validate.enable = true;
  };
};
```

## Backward Compatibility

All existing configurations will continue to work without modification:

- Single `outputPath` strings remain fully supported
- No breaking changes to existing API surface
- Internal handling converts single strings to arrays transparently

```nix
# This continues to work exactly as before
languages = {
  go = {
    enable = true;
    outputPath = "gen/go";  # Single path still supported
    grpc.enable = true;
  };
};
```

## Benefits

1. **Code Reuse**: Generate the same protobuf code to multiple locations without duplication
2. **Multi-Module Support**: Support complex project structures with multiple modules
3. **Distribution Flexibility**: Generate code for both development and distribution simultaneously
4. **Microservices Architecture**: Easily share proto definitions across multiple services
5. **Vendor Management**: Generate to both local and vendor directories

## Implementation Considerations

### Technical Requirements

1. **Path Resolution**: Ensure all output paths are properly resolved relative to project root
2. **Directory Creation**: Automatically create necessary parent directories for each path
3. **Atomic Generation**: Ensure all paths are generated successfully or none at all
4. **Performance**: Optimize for multiple path generation to minimize build time

### Validation Rules

1. **Path Validation**: Ensure all output paths are valid directory paths
2. **Uniqueness**: Prevent duplicate paths in the array
3. **Conflict Detection**: Warn about potential conflicts between different languages using same paths
4. **Relative Paths**: Ensure proper handling of both relative and absolute paths

### Error Handling

1. **Clear Error Messages**: Provide specific error messages for each output path that fails
2. **Partial Failure Handling**: Define behavior when some paths succeed and others fail
3. **Permission Errors**: Handle cases where some directories cannot be created or written to

## Documentation Updates

### Configuration Reference

Update all language-specific documentation to show array examples:

```nix
# Before
outputPath = "gen/go";

# After (both supported)
outputPath = "gen/go";                    # Single path
outputPath = ["gen/go" "pkg/proto"];      # Multiple paths
```

### Migration Guide

Provide examples for common migration scenarios:

1. **Single to Multiple**: Converting existing single-path configurations
2. **Best Practices**: Recommended patterns for different project types
3. **Common Pitfalls**: Things to avoid when using multiple paths

## Testing Strategy

1. **Unit Tests**: Test path normalization and validation logic
2. **Integration Tests**: Verify actual file generation in all specified locations
3. **Backward Compatibility**: Ensure all existing examples continue to work
4. **Edge Cases**: Test empty arrays, duplicate paths, invalid paths
5. **Performance Tests**: Measure impact of multiple path generation

## Example Implementation

Here's a simplified example of how the core logic might look:

```nix
# In mkBufrnix.nix
let
  normalizeOutputPath = path: 
    if builtins.isList path then path else [path];
    
  generateForLanguage = lang: config:
    let 
      outputPaths = normalizeOutputPath config.outputPath;
      
      generateForPath = outputPath: ''
        mkdir -p ${outputPath}
        ${protocCommand} --${lang}_out=${outputPath} ${protoFiles}
      '';
      
    in builtins.concatStringsSep "\n" (map generateForPath outputPaths);
```

## Future Enhancements

1. **Path Templates**: Support templated paths like `gen/{service}/proto`
2. **Conditional Paths**: Enable/disable specific paths based on conditions
3. **Path Validation**: More sophisticated path validation and conflict detection
4. **Symlink Support**: Option to create symlinks instead of copying files
5. **Incremental Generation**: Only regenerate changed files in each path

This specification provides a clean, backward-compatible way to support multiple output paths while maintaining Bufrnix's simplicity and ease of use.
