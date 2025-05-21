# bufrnix

Nix powered protobufs with developer tooling: cli, linter, formatter, lsp, etc.

## Introduction


Example Usage:
```nix
{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        bufrnix.url = "github:conneroisu/bufr.nix";
        bufr.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = inputs @ {
        self, 
        nixpkgs,
        bufr,
        ...
    }: {
        bufrnix = {
            root = "./proto"; # root of versioned protobuf files
            go = {
                protoc-gen-go = {
                    enable = true;
                    out = "gen/go"; # (Default) output directory relative to root
                    opt = {
                        "paths=source_relative";
                    };
                };
            };
            python = {
                enable = true;
                out = "gen/python"; # (Default) output directory relative to root
            };
        };
    }
}
```

Each step has:
- `out` (similar to `buf.build`) (e.g. `--prost-serde_out="$PROTOC_RUST_OUT"`)
- `opt` (similar to `buf.build`) (e.g. `--prost-crate_opt=gen_crate,no_features=true`)

- `package`

Defining new proto dependencies is simple as settings in nix.

```nix
# TODO: add example
```

## Supported Languages

Bufrnix currently supports code generation for the following languages:

- **Go**: Full protobuf and gRPC support with additional plugins (Connect, Gateway, Validate)
- **Dart**: Complete protobuf and gRPC client/server generation for Flutter and server applications
- **JavaScript/TypeScript**: Modern JavaScript with ES modules, gRPC-Web, and Twirp support
- **PHP**: Basic protobuf messages and Twirp RPC framework support

See the [languages documentation](src/languages/README.md) for detailed configuration options and the [examples](examples/) directory for working implementations.

## Diving Deeper

CLI = script
