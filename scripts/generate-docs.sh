#!/usr/bin/env bash

# Generate documentation for bufrnix Nix library

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
DOC_DIR="$REPO_ROOT/doc/src/content/docs/reference"

echo "Generating Nix library documentation..."
mkdir -p "$DOC_DIR"

# Generate documentation for the main library
nixdoc --category "bufrnix" \
       --description "bufrnix: Protocol Buffer Code Generation for Nix" \
       --file "$REPO_ROOT/src/lib/mkBufrnix.nix" \
       > "$DOC_DIR/nix-api.md"

# Generate documentation for options
nixdoc --category "options" \
       --description "bufrnix options: Configuration options for bufrnix" \
       --file "$REPO_ROOT/src/lib/bufrnix-options.nix" \
       > "$DOC_DIR/options.md"

# Generate MDX files with proper frontmatter for each language module
for lang_dir in "$REPO_ROOT/src/languages"/*; do
    if [ -d "$lang_dir" ]; then
        lang_name=$(basename "$lang_dir")
        if [ -f "$lang_dir/default.nix" ]; then
            echo "Generating documentation for $lang_name language module..."
            nixdoc --category "$lang_name" \
                   --description "bufrnix $lang_name: Language module for $lang_name code generation" \
                   --file "$lang_dir/default.nix" \
                   > "$DOC_DIR/lang-$lang_name.md"
        fi
    fi
done

echo "Documentation generated in $DOC_DIR"
echo "Generated files:"
ls -la "$DOC_DIR"/*.md
