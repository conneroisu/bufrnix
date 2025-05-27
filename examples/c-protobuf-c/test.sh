#!/usr/bin/env bash
set -euo pipefail

echo "Testing protobuf-c example..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Generate protobuf code
echo "1. Generating protobuf code..."
if nix build; then
    echo -e "${GREEN}✓ Code generation successful${NC}"
else
    echo -e "${RED}✗ Code generation failed${NC}"
    exit 1
fi

# Step 2: Enter dev shell and build
echo -e "\n2. Building C programs..."
nix develop --command bash -c "make clean && make all"

# Step 3: Run the test program
echo -e "\n3. Running tests..."
if nix develop --command make test; then
    echo -e "${GREEN}✓ All tests passed${NC}"
else
    echo -e "${RED}✗ Tests failed${NC}"
    exit 1
fi

# Step 4: Run the example program
echo -e "\n4. Running example program..."
nix develop --command make run

echo -e "\n${GREEN}✅ protobuf-c example test completed successfully!${NC}"