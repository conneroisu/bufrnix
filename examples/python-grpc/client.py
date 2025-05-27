#!/usr/bin/env python3
"""gRPC client example."""

import grpc
import sys
sys.path.insert(0, '.')

from proto.gen.python import greeter_pb2
from proto.gen.python import greeter_pb2_grpc


def run():
    with grpc.insecure_channel('localhost:50051') as channel:
        stub = greeter_pb2_grpc.GreeterStub(channel)
        
        # Simple RPC
        print("Making simple RPC...")
        response = stub.SayHello(greeter_pb2.HelloRequest(name='Bufrnix'))
        print(f"Response: {response.message} (timestamp: {response.timestamp})")
        
        # Streaming RPC
        print("\nMaking streaming RPC...")
        for response in stub.SayHelloStream(greeter_pb2.HelloRequest(name='Bufrnix')):
            print(f"Stream response: {response.message}")


if __name__ == '__main__':
    run()