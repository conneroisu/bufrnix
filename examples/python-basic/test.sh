#!/usr/bin/env bash
set -euo pipefail

echo "Testing Basic Python Protobuf Generation"
echo "======================================="

# Clean previous runs
rm -rf proto/gen

# Initialize and generate
bufrnix_init
bufrnix

echo ""
echo "Generated files:"
find proto/gen -name "*.py" -type f | sort

echo ""
echo "Testing generated code:"
python test.py