# Documentation Example

This example demonstrates how to use bufrnix to generate documentation from Protocol Buffer files using protoc-gen-doc.

## Usage

1. Generate the documentation:
   ```bash
   nix build
   ```

2. View the generated documentation:
   ```bash
   open proto/gen/doc/index.html
   ```

## Configuration

The documentation generation is configured in `flake.nix`:

```nix
languages.doc = {
  enable = true;
  outputPath = "proto/gen/doc";
  format = "html";
  outputFile = "index.html";
};
```

## Supported Formats

The `format` option supports:
- `html` - HTML documentation (default)
- `markdown` - Markdown documentation
- `json` - JSON representation
- `docbook` - DocBook XML format

## Example Output

The generated documentation includes:
- Message definitions with field descriptions
- Service definitions with RPC methods
- Enumerations and their values
- Package and import information