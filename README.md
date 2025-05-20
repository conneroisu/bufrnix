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

## Diving Deeper

CLI = script
