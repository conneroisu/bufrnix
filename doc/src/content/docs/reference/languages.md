---
title: Language Support
description: Detailed information about supported languages and their plugins in Bufrnix.
---

# Language Support

Bufrnix provides extensive support for generating Protocol Buffer code across multiple programming languages. This page details the available languages and their specific plugins and features.

## Go

Go is fully supported with a rich set of plugins for different RPC frameworks.

### Base Support

```nix
go = {
  enable = true;
  out = "gen/go"; # Default output directory

  # Common options
  opt = {
    "paths=source_relative" = null;
  };
};
```

### gRPC Support

The standard gRPC plugin for Go:

```nix
go = {
  enable = true;
  grpc = {
    enable = true;
    opt = { /* additional options */ };
  };
};
```

### Connect Support

[Connect](https://connectrpc.com/) is a family of libraries for building browser and gRPC-compatible HTTP APIs:

```nix
go = {
  enable = true;
  connect = {
    enable = true;
    opt = { /* additional options */ };
  };
};
```

### gRPC-Gateway Support

[gRPC-Gateway](https://github.com/grpc-ecosystem/grpc-gateway) generates a reverse-proxy server to translate RESTful HTTP APIs to gRPC:

```nix
go = {
  enable = true;
  gateway = {
    enable = true;
    opt = { /* additional options */ };
  };
};
```

### Validation Support

[protoc-gen-validate](https://github.com/bufbuild/protoc-gen-validate) provides field validation code generation:

```nix
go = {
  enable = true;
  validate = {
    enable = true;
    opt = { /* additional options */ };
  };
};
```

## Dart

Dart support is ideal for Flutter applications and Dart server code.

### Base Support

```nix
dart = {
  enable = true;
  out = "gen/dart"; # Default output directory

  # Common options
  opt = { /* options */ };
};
```

### gRPC Support

Includes full support for gRPC client and server code:

```nix
dart = {
  enable = true;
  grpc = {
    enable = true;
    opt = { /* additional options */ };
  };
};
```

## JavaScript/TypeScript

JavaScript and TypeScript support includes modern ES modules and multiple RPC frameworks.

### Base Support

```nix
js = {
  enable = true;
  out = "gen/js"; # Default output directory

  # Common options
  opt = {
    "import_style=commonjs" = null; # or "import_style=es6"
    "binary" = null; # Generate binary serialization/deserialization
  };
};
```

### gRPC-Web Support

[gRPC-Web](https://github.com/grpc/grpc-web) provides browser-compatible gRPC clients:

```nix
js = {
  enable = true;
  grpcWeb = {
    enable = true;
    mode = "grpcwebtext"; # or "grpcweb"
    opt = { /* additional options */ };
  };
};
```

### Twirp Support

[Twirp](https://github.com/twitchtv/twirp) is a simple RPC framework built on Protocol Buffers:

```nix
js = {
  enable = true;
  twirp = {
    enable = true;
    opt = { /* additional options */ };
  };
};
```

## PHP

PHP support includes basic Protocol Buffer serialization and the Twirp RPC framework.

### Base Support

```nix
php = {
  enable = true;
  out = "gen/php"; # Default output directory

  # Common options
  opt = { /* options */ };
};
```

### Twirp Support

PHP implementation of the Twirp RPC framework:

```nix
php = {
  enable = true;
  twirp = {
    enable = true;
    opt = { /* additional options */ };
  };
};
```

## Language Feature Matrix

| Feature          | Go  | Dart | JS/TS | PHP |
| ---------------- | --- | ---- | ----- | --- |
| Basic Messages   | ✅  | ✅   | ✅    | ✅  |
| gRPC             | ✅  | ✅   | ❌    | ❌  |
| gRPC-Web         | ❌  | ❌   | ✅    | ❌  |
| Connect          | ✅  | ❌   | ❌    | ❌  |
| gRPC-Gateway     | ✅  | ❌   | ❌    | ❌  |
| Twirp            | ❌  | ❌   | ✅    | ✅  |
| Field Validation | ✅  | ❌   | ❌    | ❌  |

## Adding Language Support

Bufrnix is designed to be extensible. Each language is implemented as a module in the `src/languages/` directory.

To add support for a new language:

1. Create a new directory in `src/languages/` (e.g., `src/languages/rust/`)
2. Implement the required interface in `default.nix` and any plugin-specific files
3. Update `src/lib/bufrnix-options.nix` to include options for the new language
4. Update the documentation to reflect the new language support

For more details, see the [Contributing Guide](/guides/contributing/) and the [Module Template](https://github.com/conneroisu/bufrnix/blob/main/src/languages/module-template.nix) file.
