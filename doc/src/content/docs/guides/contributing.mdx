---
title: Contributing to Bufrnix
description: Guidelines for contributing to the Bufrnix project, including adding new language support.
---

Bufrnix is an open-source project, and contributions are welcome! This guide explains how to contribute to Bufrnix, whether you're adding new features, fixing bugs, or improving documentation.

## Getting Started

1. **Fork the repository**: Start by forking the [Bufrnix repository](https://github.com/conneroisu/bufrnix) on GitHub.

2. **Clone your fork**: Clone your fork to your local machine:

   ```bash
   git clone https://github.com/your-username/bufrnix.git
   cd bufrnix
   ```

3. **Set up the development environment**:
   ```bash
   # Enter the Nix development shell
   nix develop
   ```

## Project Structure

Understanding the project structure will help you navigate and modify the codebase:

```
bufrnix/
├── doc/                    # Documentation site
├── examples/               # Example projects
├── flake.nix               # Main Nix flake file
├── src/
│   ├── languages/          # Language-specific modules
│   │   ├── dart/
│   │   ├── go/
│   │   ├── js/
│   │   ├── php/
│   │   └── ...
│   └── lib/                # Core library code
│       ├── bufrnix-options.nix  # Configuration schema
│       ├── mkBufrnix.nix        # Main implementation
│       └── utils/
└── README.md
```

## Adding a New Language Module

To add support for a new programming language to Bufrnix:

1. **Create a language directory**:
   Create a new directory under `src/languages/` with the name of your language (e.g., `src/languages/rust/`).

2. **Implement the language module**:
   Create a `default.nix` file in your language directory that follows the language module interface:

   ```nix
   # src/languages/rust/default.nix
   { pkgs, lib, config, ... }:

   let
     cfg = config.bufrnix.rust;
   in {
     # Runtime inputs required for code generation
     runtimeInputs = with pkgs; [
       # Required packages for Rust code generation
       protobuf
       rustPackages.prost-build
     ];

     # Protoc plugin configuration
     protocPlugins = [
       {
         name = "rust";
         package = pkgs.rustPackages.protoc-gen-prost;
         out = cfg.out;
         opt = cfg.opt;
       }
     ];

     # Command options for protoc
     commandOptions = [
       # Additional command line options
     ];

     # Initialization hooks
     initHooks = ''
       echo "Initializing Rust code generation..."
       mkdir -p ${cfg.out}
     '';

     # Code generation hooks
     generateHooks = ''
       echo "Generating Rust code..."
       # Additional shell code for Rust-specific tasks
     '';
   }
   ```

3. **Add gRPC or other plugin support**:
   Create additional files for plugin-specific functionality (e.g., `grpc.nix`):

   ```nix
   # src/languages/rust/grpc.nix
   { pkgs, lib, config, ... }:

   let
     cfg = config.bufrnix.rust.grpc;
   in {
     # Implementation for gRPC support
     # ...
   }
   ```

4. **Update configuration schema**:
   Add your language's configuration options to `src/lib/bufrnix-options.nix`:

   ```nix
   # Add to the language options
   rust = {
     enable = mkEnableOption "Rust code generation";

     out = mkOption {
       type = types.str;
       default = "gen/rust";
       description = "Output directory for Rust code";
     };

     opt = mkOption {
       type = types.attrsOf types.nullOr;
       default = {};
       description = "Options for Rust code generation";
     };

     # Additional plugin-specific options
     grpc = {
       enable = mkEnableOption "gRPC support for Rust";
       # ...
     };
   };
   ```

5. **Test your implementation**:
   Create an example project that uses your new language module and test that code generation works correctly.

6. **Update documentation**:
   Add documentation for your new language module in the appropriate places, including:
   - Update the language support reference
   - Add an example project if possible
   - Update the README.md with the new supported language

## Pull Request Process

1. **Create a branch**:

   ```bash
   git checkout -b feature/new-language-support
   ```

2. **Make your changes**:
   Implement your feature or fix following the guidelines above.

3. **Commit your changes**:

   ```bash
   git commit -m "Add Rust language support"
   ```

4. **Push to your fork**:

   ```bash
   git push origin feature/new-language-support
   ```

5. **Create a pull request**:
   Go to the Bufrnix repository on GitHub and create a pull request from your branch.

6. **Address review feedback**:
   Respond to any feedback from maintainers and update your pull request as needed.

## Code Style and Guidelines

- Follow the existing code style in the project.
- Keep language modules modular and consistent with the existing ones.
- Ensure all options have proper documentation.
- Add appropriate error handling and validation.
- Consider compatibility with existing tools like `buf.build`.

## Testing

Before submitting a pull request, test your changes:

1. **Test with an example project**:
   Create or modify an example project that uses your changes.

2. **Verify code generation**:
   Ensure that the generated code compiles and works correctly.

3. **Run existing tests**:
   If there are existing automated tests, make sure they pass with your changes.

## Documentation

Good documentation is crucial for the project:

1. **Update the reference docs**:
   Ensure that your feature is properly documented in the reference section.

2. **Add example code**:
   Provide example code that demonstrates how to use your feature.

3. **Update the main README**:
   If your change adds significant functionality, update the main README.md file.

## Questions and Help

If you have questions or need help with your contribution:

- Open an issue on GitHub
- Reach out to the maintainers
- Check the existing documentation and code for guidance

Thank you for contributing to Bufrnix! Your efforts help make Protocol Buffer development with Nix better for everyone.
