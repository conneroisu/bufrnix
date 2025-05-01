# Bufrnix - Phase 1 TODO

## Core Package Structure

- [ ] Create src/lib directory
- [ ] Implement bufrnix-options.nix with basic options
- [ ] Create mkBufrnix.nix skeleton
- [ ] Implement debug.nix with basic logging functionality
- [ ] Create package exports in flake.nix
- [ ] Set up cross-platform support for multiple systems

## Protoc Wrapper for Go

- [ ] Add Go language configuration options
- [ ] Implement protoc command generation for Go
- [ ] Create Go-specific output handling
- [ ] Implement package prefix functionality
- [ ] Support Opts for Go
- [ ] Set up handling for multiple proto files
- [ ] Test with basic proto definitions

## Initialization Script

- [ ] Create bufrnix_init wrapper command
- [ ] Implement basic directory structure creation
- [ ] Add template proto file generation
- [ ] Create default buf.yaml for linting
- [ ] Generate example service definition
- [ ] Add command-line help information
- [ ] Test initialization with different options

## Debug Functionality

- [ ] Set up environment variable handling
- [ ] Implement verbosity levels
- [ ] Create log file handling
- [ ] Add command printing functionality
- [ ] Implement error context enhancement
- [ ] Add timing metrics for commands
- [ ] Test debug output with different verbosity levels

## Command Line Interface

- [ ] Implement bufrnix_generate command
- [ ] Create bufrnix_lint command (basic version)
- [ ] Implement command-line argument parsing
- [ ] Add help text for all commands
- [ ] Create bash completion script
- [ ] Add version printing functionality
- [ ] Test CLI with various arguments

## Testing

- [ ] Create test proto file with basic definitions
- [ ] Implement unit tests for protoc command generation
- [ ] Create test for directory structure validation
- [ ] Add test for Go code generation
- [ ] Implement integration test with simple service
- [ ] Create test for error handling
- [ ] Set up testing framework for future phases
