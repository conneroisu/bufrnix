#!/usr/bin/env python3
"""gRPC server example."""

import time
import grpc
from concurrent import futures
import sys
sys.path.insert(0, '.')

from proto.gen.python import greeter_pb2
from proto.gen.python import greeter_pb2_grpc


class GreeterServicer(greeter_pb2_grpc.GreeterServicer):
    def SayHello(self, request, context):
        return greeter_pb2.HelloReply(
            message=f"Hello, {request.name}!",
            timestamp=int(time.time())
        )
    
    def SayHelloStream(self, request, context):
        for i in range(5):
            yield greeter_pb2.HelloReply(
                message=f"Hello #{i}, {request.name}!",
                timestamp=int(time.time())
            )
            time.sleep(1)


def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    greeter_pb2_grpc.add_GreeterServicer_to_server(GreeterServicer(), server)
    server.add_insecure_port('[::]:50051')
    print("Server starting on port 50051...")
    server.start()
    
    try:
        server.wait_for_termination()
    except KeyboardInterrupt:
        print("\nShutting down...")
        server.stop(0)


if __name__ == '__main__':
    serve()