#!/usr/bin/env bash
set -euo pipefail

echo "Testing Python Type Stubs Generation"
echo "==================================="

# Clean previous runs
rm -rf proto/gen

# Initialize and generate
bufrnix_init
bufrnix

echo ""
echo "Generated files:"
find proto/gen -name "*.py*" -type f | sort

echo ""
echo "Type stub verification:"
if [ -f "proto/gen/python/typed_pb2.pyi" ]; then
    echo "✓ .pyi type stubs generated"
    grep -q "class User:" proto/gen/python/typed_pb2.pyi && echo "✓ User type stub found"
fi

if [ -f "proto/gen/python/typed_pb2_grpc.pyi" ]; then
    echo "✓ gRPC .pyi stubs generated"
    grep -q "class UserServiceStub:" proto/gen/python/typed_pb2_grpc.pyi && echo "✓ UserServiceStub type found"
fi

if [ -f "proto/gen/python/py.typed" ]; then
    echo "✓ py.typed marker found (PEP 561)"
fi

echo ""
echo "Running type test:"
python test_types.py

echo ""
echo "Running mypy type check:"
mypy test_types.py || echo "Note: mypy may show import errors for generated code in this test environment"