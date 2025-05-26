#!/usr/bin/env bash
set -euo pipefail

echo "Testing Python gRPC Generation"
echo "============================="

# Clean previous runs
rm -rf proto/gen

# Initialize and generate
bufrnix_init
bufrnix

echo ""
echo "Generated files:"
find proto/gen -name "*.py" -type f | sort

echo ""
echo "Generated gRPC service check:"
if [ -f "proto/gen/python/greeter_pb2_grpc.py" ]; then
    echo "✓ gRPC service stubs generated"
    grep -q "class GreeterStub" proto/gen/python/greeter_pb2_grpc.py && echo "✓ GreeterStub found"
    grep -q "class GreeterServicer" proto/gen/python/greeter_pb2_grpc.py && echo "✓ GreeterServicer found"
else
    echo "✗ gRPC service stubs NOT generated"
fi