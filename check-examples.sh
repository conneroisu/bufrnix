#!/usr/bin/env bash

# Simple check script for use in nix flake check
# This script only runs linting checks that don't require network access

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the linter script
if [[ ! -x "${SCRIPT_DIR}/lint-examples.sh" ]]; then
    echo "Error: ${SCRIPT_DIR}/lint-examples.sh is missing or not executable." >&2
    exit 1
fi
exec "${SCRIPT_DIR}/lint-examples.sh" "$@"
