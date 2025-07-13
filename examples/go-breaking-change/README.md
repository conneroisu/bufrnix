# Breaking Change Detection Example

This example demonstrates Bufrnix's breaking change detection feature, which helps maintain API compatibility during Protocol Buffer schema evolution.

## Overview

Breaking change detection automatically validates that your protobuf schema changes don't introduce compatibility issues that could break existing clients. This is essential for maintaining backward compatibility in distributed systems and APIs.

## Features Demonstrated

- **Automatic Breaking Change Detection**: Runs before code generation
- **Git-based Comparison**: Compares current schema against a git reference
- **Configurable Modes**: Backward, forward, or full compatibility checking
- **Rule Customization**: Ignore specific breaking change rules when needed
- **Integration with Buf CLI**: Uses the industry-standard buf tool for validation

## Configuration

The breaking change detection is configured in `flake.nix`:

```nix
breaking = {
  enable = true;
  mode = "backward";           # Check backward compatibility
  baseReference = "HEAD~1";    # Compare against previous commit
  failOnBreaking = true;       # Fail build if breaking changes found
  outputFormat = "text";       # Human-readable output
  ignoreRules = [];           # No rules ignored by default
  buf = {
    timeout = 30;             # 30-second timeout for buf command
  };
};
```

## Getting Started

1. **Enter the development environment:**
   ```bash
   nix develop
   ```

2. **Generate code (with breaking change detection):**
   ```bash
   nix run
   ```

3. **Initialize git repository to test breaking changes:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit with user schema"
   ```

## Testing Breaking Changes

### Example 1: Safe Change (Adding Optional Field)

1. Add a new optional field to the `User` message:
   ```protobuf
   message User {
     string id = 1;
     string email = 2;
     string name = 3;
     UserStatus status = 4;
     google.protobuf.Timestamp created_at = 5;
     google.protobuf.Timestamp last_login = 6;
     
     // New optional field - this is backward compatible
     string phone_number = 7;
   }
   ```

2. Commit the change:
   ```bash
   git add proto/user/v1/user.proto
   git commit -m "Add optional phone_number field"
   ```

3. Run code generation:
   ```bash
   nix run
   ```
   ✅ This should succeed - adding optional fields is backward compatible.

### Example 2: Breaking Change (Removing Field)

1. Remove the `last_login` field from the `User` message:
   ```protobuf
   message User {
     string id = 1;
     string email = 2;
     string name = 3;
     UserStatus status = 4;
     google.protobuf.Timestamp created_at = 5;
     // Removed: google.protobuf.Timestamp last_login = 6;
   }
   ```

2. Commit the change:
   ```bash
   git add proto/user/v1/user.proto
   git commit -m "Remove last_login field"
   ```

3. Run code generation:
   ```bash
   nix run
   ```
   ❌ This should fail - removing fields breaks backward compatibility.

### Example 3: Breaking Change (Changing Field Type)

1. Change the `id` field from `string` to `int64`:
   ```protobuf
   message User {
     int64 id = 1;  // Changed from string to int64
     string email = 2;
     // ... rest of fields
   }
   ```

2. Commit and test:
   ```bash
   git add proto/user/v1/user.proto
   git commit -m "Change user ID to int64"
   nix run
   ```
   ❌ This should fail - changing field types breaks compatibility.

## Compatibility Modes

### Backward Compatibility (default)
- **Safe**: Adding optional fields, adding enum values, adding services/methods
- **Breaking**: Removing fields, changing field types, removing enum values, changing field numbers

### Forward Compatibility
- **Safe**: Removing optional fields, removing services/methods  
- **Breaking**: Adding required fields, changing field numbers

### Full Compatibility
- Most restrictive: Only allows safe additions that work in both directions

## Configuration Options

### Ignoring Specific Rules

Sometimes you need to make breaking changes intentionally. You can ignore specific rules:

```nix
breaking = {
  enable = true;
  ignoreRules = [
    "FIELD_REMOVED"          # Allow field removal
    "ENUM_VALUE_REMOVED"     # Allow enum value removal
    "SERVICE_REMOVED"        # Allow service removal
  ];
};
```

### Warning Mode

To detect breaking changes but not fail the build:

```nix
breaking = {
  enable = true;
  failOnBreaking = false;    # Show warnings but don't fail
};
```

### Different Base References

Compare against different git references:

```nix
breaking = {
  baseReference = "origin/main";    # Compare against main branch
  # baseReference = "v1.0.0";       # Compare against a tag
  # baseReference = "HEAD~5";       # Compare against 5 commits ago
};
```

## Manual Breaking Change Detection

You can also run buf breaking manually:

```bash
# Check against previous commit
buf breaking --against .git#branch=HEAD~1

# Check against main branch
buf breaking --against .git#branch=origin/main

# Check with specific format
buf breaking --against .git#branch=HEAD~1 --format json
```

## Common Breaking Changes to Avoid

1. **Field Changes**:
   - ❌ Removing fields
   - ❌ Changing field types
   - ❌ Changing field numbers
   - ❌ Changing field names
   - ❌ Adding required fields

2. **Enum Changes**:
   - ❌ Removing enum values
   - ❌ Changing enum value numbers

3. **Service Changes**:
   - ❌ Removing services or methods
   - ❌ Changing method signatures

## Safe Changes

1. **Field Changes**:
   - ✅ Adding optional fields
   - ✅ Adding repeated fields
   - ✅ Deprecating fields (with proper field options)

2. **Enum Changes**:
   - ✅ Adding new enum values
   - ✅ Deprecating enum values

3. **Service Changes**:
   - ✅ Adding new services
   - ✅ Adding new methods

## Integration with CI/CD

Breaking change detection integrates seamlessly with CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Generate protobuf code with breaking change detection
  run: |
    nix develop -c bash -c "
      git fetch origin main
      nix run .#breaking-check
    "
```

## Troubleshooting

### Error: "Not in a git repository"
Ensure you're in a git repository and have made at least one commit.

### Error: "Base reference not found"
Check that the specified `baseReference` exists:
```bash
git rev-parse --verify HEAD~1
```

### Error: "buf command timed out"
Increase the timeout in your configuration:
```nix
breaking.buf.timeout = 120;  # 2 minutes
```

## Related Documentation

- [Buf Breaking Change Detection](https://docs.buf.build/breaking)
- [Protobuf Style Guide](https://developers.google.com/protocol-buffers/docs/style)
- [API Evolution Best Practices](https://developers.google.com/protocol-buffers/docs/overview#evolution)

## Files in This Example

- `flake.nix` - Bufrnix configuration with breaking change detection
- `proto/user/v1/user.proto` - Example protocol buffer schema
- `buf.yaml` - Buf configuration for linting and breaking change rules
- `README.md` - This documentation file

This example demonstrates how Bufrnix's breaking change detection helps maintain API compatibility while enabling safe schema evolution.