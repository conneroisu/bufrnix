# Bufrnix - Phase 1 TODO

Each task is marked with a checkmark if it has been completed. To mark a task as completed, test the simple-flake and ensure expected behavior is observed.
## Core Package Structure

- [x] Create src/lib directory
- [x] Implement bufrnix-options.nix with basic options
- [x] Create mkBufrnix.nix skeleton
- [x] Implement debug.nix with basic logging functionality
- [x] Create package exports in flake.nix
- [x] Set up cross-platform support for multiple systems

## Protoc Wrapper for Go

- [x] Add Go language configuration options
- [x] Implement protoc command generation for Go
- [x] Create Go-specific output handling
- [x] Implement package prefix functionality
- [x] Support Opts for Go
- [x] Set up handling for multiple proto files
- [ ] Test with basic proto definitions

## Initialization Script

- [x] Create bufrnix_init wrapper command
- [x] Implement basic directory structure creation
- [x] Add template proto file generation
- [x] Create default buf.yaml for linting
- [x] Generate example service definition
- [x] Add command-line help information
- [ ] Test initialization with different options

## Debug Functionality

- [x] Set up environment variable handling
- [x] Implement verbosity levels
- [x] Create log file handling
- [x] Add command printing functionality
- [x] Implement error context enhancement
- [x] Add timing metrics for commands
- [ ] Test debug output with different verbosity levels

## Command Line Interface

- [x] Implement bufrnix_generate command
- [x] Create bufrnix_lint command (basic version)
- [x] Implement command-line argument parsing
- [x] Add help text for all commands
- [ ] Create bash completion script
- [x] Add version printing functionality
- [ ] Test CLI with various arguments

## Testing

- [x] Create test proto file with basic definitions
- [ ] Implement unit tests for protoc command generation
- [ ] Create test for directory structure validation
- [ ] Add test for Go code generation
- [ ] Implement integration test with simple service
- [ ] Create test for error handling
- [ ] Set up testing framework for future phases

## Additional Language Support (Future Phases)

- [ ] Add support for TypeScript
- [ ] Add support for Python
- [ ] Add support for Rust
- [ ] Add support for Java
- [ ] Add support for C++
