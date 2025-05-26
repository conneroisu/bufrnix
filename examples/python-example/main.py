#!/usr/bin/env python3
"""
Example Python client using generated protobuf and gRPC code.
"""

import asyncio
import time
from typing import List

# Import generated protobuf messages
from proto.gen.python.example.v1 import example_pb2
from proto.gen.python.example.v1 import example_pb2_grpc

import grpc


class GreetingClient:
    """Example client for the Greeting service."""
    
    def __init__(self, channel: grpc.Channel):
        self.stub = example_pb2_grpc.GreetingServiceStub(channel)
    
    def create_greeting(self, content: str, tags: List[str] = None) -> example_pb2.Greeting:
        """Create a new greeting."""
        request = example_pb2.CreateGreetingRequest(
            content=content,
            tags=tags or []
        )
        response = self.stub.CreateGreeting(request)
        return response.greeting
    
    def list_greetings(self, page_size: int = 10, page_token: str = "") -> example_pb2.ListGreetingsResponse:
        """List greetings with pagination."""
        request = example_pb2.ListGreetingsRequest(
            page_size=page_size,
            page_token=page_token
        )
        return self.stub.ListGreetings(request)
    
    def stream_greetings(self, page_size: int = 10):
        """Stream greetings as they arrive."""
        request = example_pb2.ListGreetingsRequest(page_size=page_size)
        for greeting in self.stub.StreamGreetings(request):
            yield greeting


def example_protobuf_usage():
    """Demonstrate basic protobuf usage without gRPC."""
    print("=== Protobuf Example ===")
    
    # Create a greeting message
    greeting = example_pb2.Greeting(
        id="greeting-001",
        content="Hello, Bufrnix!",
        created_at=int(time.time()),
        tags=["example", "python", "bufrnix"]
    )
    
    # Add metadata
    greeting.metadata["author"] = "bufrnix"
    greeting.metadata["version"] = "1.0.0"
    
    print(f"Created greeting: {greeting.id}")
    print(f"Content: {greeting.content}")
    print(f"Tags: {list(greeting.tags)}")
    print(f"Metadata: {dict(greeting.metadata)}")
    
    # Serialize to bytes
    serialized = greeting.SerializeToString()
    print(f"\nSerialized size: {len(serialized)} bytes")
    
    # Deserialize from bytes
    deserialized = example_pb2.Greeting()
    deserialized.ParseFromString(serialized)
    print(f"Deserialized content: {deserialized.content}")
    
    # JSON serialization (requires protobuf>=3.20)
    from google.protobuf.json_format import MessageToJson, Parse
    json_str = MessageToJson(greeting)
    print(f"\nJSON representation:\n{json_str}")


def example_grpc_client():
    """Demonstrate gRPC client usage (requires a running server)."""
    print("\n=== gRPC Client Example ===")
    print("Note: This requires a gRPC server running on localhost:50051")
    
    try:
        # Create a channel and client
        with grpc.insecure_channel('localhost:50051') as channel:
            client = GreetingClient(channel)
            
            # Create a greeting
            greeting = client.create_greeting(
                content="Hello from Python client!",
                tags=["python", "grpc", "example"]
            )
            print(f"Created greeting via gRPC: {greeting.id}")
            
            # List greetings
            response = client.list_greetings(page_size=5)
            print(f"Found {len(response.greetings)} greetings")
            
    except grpc.RpcError as e:
        print(f"gRPC error: {e.code()} - {e.details()}")
        print("Make sure a gRPC server is running on localhost:50051")


async def example_async_usage():
    """Demonstrate async patterns with generated code."""
    print("\n=== Async Example ===")
    
    # Create multiple greetings asynchronously
    greetings = []
    for i in range(5):
        greeting = example_pb2.Greeting(
            id=f"async-{i}",
            content=f"Async greeting #{i}",
            created_at=int(time.time())
        )
        greetings.append(greeting)
    
    print(f"Created {len(greetings)} async greetings")
    
    # Simulate async processing
    await asyncio.sleep(0.1)
    print("Async processing complete")


def demonstrate_type_safety():
    """Show type safety with generated stubs."""
    print("\n=== Type Safety Example ===")
    
    # With mypy stubs, this would be caught at type check time
    greeting = example_pb2.Greeting()
    
    # Type-safe field access
    greeting.id = "type-safe-001"
    greeting.content = "Type-checked greeting"
    greeting.created_at = int(time.time())
    
    # The following would be caught by mypy:
    # greeting.id = 123  # Error: expects str, not int
    # greeting.unknown_field = "value"  # Error: no such field
    
    print("Type-safe greeting created successfully")
    print(f"All fields have proper types: id={type(greeting.id).__name__}, "
          f"created_at={type(greeting.created_at).__name__}")


def main():
    """Run all examples."""
    print("Python Bufrnix Example")
    print("===================")
    
    # Basic protobuf usage
    example_protobuf_usage()
    
    # gRPC client example (optional)
    # example_grpc_client()
    
    # Async example
    asyncio.run(example_async_usage())
    
    # Type safety demonstration
    demonstrate_type_safety()
    
    print("\n✅ All examples completed successfully!")


if __name__ == "__main__":
    main()