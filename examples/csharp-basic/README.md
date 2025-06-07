# C# Basic Protocol Buffers Example

This example demonstrates basic Protocol Buffers usage with C# and Bufrnix.

## Features

- Basic message definition (Person, AddressBook)
- Nested messages and enums
- Binary serialization/deserialization
- JSON serialization/deserialization
- Generated C# project file

## Structure

- `proto/` - Protocol buffer definitions
- `Program.cs` - Example C# application
- `flake.nix` - Nix flake configuration with Bufrnix

## Building

```bash
# Generate proto code
nix build .#proto

# Build the application
nix build

# Or enter development shell
nix develop

# Run directly with dotnet
dotnet run
```

## Generated Code

The generated code includes:

- C# classes for all messages
- Serialization/deserialization methods
- JSON support via Google.Protobuf
- A complete .csproj file

## Using Dependencies

There is also a manual method: First, restore the packages to the out directory, ensure you have cloned the upstream repository and you are inside it.

```bash
dotnet restore --packages out
```

Next, use nuget-to-json tool provided in nixpkgs to generate a lockfile to deps.json from the packages inside the out directory.

```bash
nuget-to-json out > deps.json
```
