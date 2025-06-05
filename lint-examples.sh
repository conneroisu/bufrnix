#!/usr/bin/env bash

# Linter script to check that all example flake.nix files have the commented bufrnix origin URL
# for ease of copy/use by users. This script is designed to run in nix flake check without network access.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
EXAMPLES_DIR="${REPO_ROOT}/examples"
REQUIRED_COMMENT="# bufrnix.url = \"github:conneroisu/bufrnix\""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

exit_code=0
checked_files=0
missing_comment_files=()

echo "🔍 Checking example flake.nix files for commented bufrnix origin URL..."
echo "Required comment: ${REQUIRED_COMMENT}"
echo

# Check we're in the right directory
if [ ! -f "flake.nix" ] || [ ! -d "examples" ]; then
    echo -e "${RED}Error: This script must be run from the bufrnix root directory${NC}"
    echo -e "${RED}Current directory: $(pwd)${NC}"
    exit 1
fi

# Find all flake.nix files in examples directory
while IFS= read -r -d '' flake_file; do
    checked_files=$((checked_files + 1))
    relative_path="${flake_file#${REPO_ROOT}/}"
    
    if grep -qF "${REQUIRED_COMMENT}" "${flake_file}"; then
        echo -e "✅ ${GREEN}${relative_path}${NC} - has required comment"
    else
        echo -e "❌ ${RED}${relative_path}${NC} - missing required comment"
        missing_comment_files+=("${relative_path}")
        exit_code=1
    fi
done < <(find "${EXAMPLES_DIR}" -name "flake.nix" -type f -print0)

echo
echo "📊 Summary:"
echo "  Checked files: ${checked_files}"
echo "  Files with comment: $((checked_files - ${#missing_comment_files[@]}))"
echo "  Files missing comment: ${#missing_comment_files[@]}"

if [ ${#missing_comment_files[@]} -gt 0 ]; then
    echo
    echo -e "${YELLOW}Files missing the required comment:${NC}"
    for file in "${missing_comment_files[@]}"; do
        echo "  - ${file}"
    done
    echo
    echo -e "${YELLOW}To fix these files, add the following comment in the inputs section:${NC}"
    echo "  ${REQUIRED_COMMENT}"
fi

echo
if [ $exit_code -eq 0 ]; then
    echo -e "🎉 ${GREEN}All example flake.nix files have the required commented bufrnix URL!${NC}"
else
    echo -e "💥 ${RED}Some example flake.nix files are missing the required commented bufrnix URL.${NC}"
fi

exit $exit_code