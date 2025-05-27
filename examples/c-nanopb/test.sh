#!/usr/bin/env bash
set -euo pipefail

echo "Testing nanopb example..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Generate protobuf code
echo "1. Generating nanopb code..."
if nix build; then
    echo -e "${GREEN}✓ Code generation successful${NC}"
else
    echo -e "${RED}✗ Code generation failed${NC}"
    exit 1
fi

# Step 2: Check that options file was used
echo -e "\n2. Verifying options file was applied..."
if grep -q "fixed_count.*true" proto/gen/c/nanopb/sensor/v1/sensor.pb.h 2>/dev/null || \
   grep -q "pb_byte_t.*values\[10\]" proto/gen/c/nanopb/sensor/v1/sensor.pb.h 2>/dev/null; then
    echo -e "${GREEN}✓ Options file constraints applied${NC}"
else
    echo -e "${RED}✗ Options file may not have been applied${NC}"
fi

# Step 3: Enter dev shell and build
echo -e "\n3. Building C programs..."
nix develop --command bash -c "make clean && make all"

# Step 4: Run the test program
echo -e "\n4. Running tests..."
if nix develop --command make test; then
    echo -e "${GREEN}✓ All tests passed${NC}"
else
    echo -e "${RED}✗ Tests failed${NC}"
    exit 1
fi

# Step 5: Run the example program
echo -e "\n5. Running example program..."
nix develop --command make run

echo -e "\n${GREEN}✅ nanopb example test completed successfully!${NC}"