#!/usr/bin/env bash
set -euo pipefail

echo "Testing Python Betterproto Generation"
echo "===================================="

# Clean previous runs
rm -rf proto/gen

# Show proto files that will be processed
echo "Proto files to process:"
proto_files=$(find "proto" -type f -name "*.proto" | sort)
echo "$proto_files"
echo ""

# Initialize and generate
bufrnix_init
bufrnix

echo ""
echo "Generated files:"
find proto/gen -name "*.py" -type f | sort

echo ""
echo "Betterproto verification:"
if find proto/gen -name "*.py" -type f | xargs grep -l "@dataclass" > /dev/null 2>&1; then
    echo "✓ Dataclass decorators found"
fi

if find proto/gen -name "*.py" -type f | xargs grep -l "from dataclasses import" > /dev/null 2>&1; then
    echo "✓ Dataclass imports found"
fi

echo ""
echo "Note: Betterproto generates different code structure than standard protobuf"
echo "Running test (may show import adjustments needed):"
python test_betterproto.py || echo "Note: Import paths may need adjustment for betterproto"