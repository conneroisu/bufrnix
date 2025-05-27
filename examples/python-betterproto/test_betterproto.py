#!/usr/bin/env python3
"""Test betterproto's modern Python approach."""

import asyncio
import sys
sys.path.insert(0, '.')

# Import will be from betterproto generated code
# The import path may differ from standard protobuf
try:
    from proto.gen.python.modern import Product, ProductService, CreateProductRequest
except ImportError:
    print("Note: Betterproto may generate different import paths")
    print("Checking alternative paths...")
    from proto.gen.python import modern


async def test_dataclasses():
    """Test betterproto's dataclass features."""
    # Betterproto uses dataclasses with proper __init__
    product = Product(
        id="prod-123",
        name="Amazing Product",
        description="This is a test product",
        price=99.99,
        categories=["electronics", "gadgets"],
        attributes={"color": "blue", "size": "medium"}
    )
    
    # Dataclass features work naturally
    print(f"Product: {product.name}")
    print(f"Price: ${product.price}")
    print(f"Categories: {', '.join(product.categories)}")
    
    # Betterproto has nicer repr
    print(f"\nProduct repr: {product}")
    
    # Serialization is still available
    data = bytes(product)
    print(f"\nSerialized size: {len(data)} bytes")
    
    # Deserialization with parse
    parsed = Product.parse(data)
    print(f"Parsed product: {parsed.name}")
    
    # Equality works naturally
    assert product == parsed
    print("✓ Equality check passed")


async def test_service():
    """Test betterproto's service approach."""
    # Create request using dataclass constructor
    request = CreateProductRequest(
        product=Product(
            id="new-prod",
            name="New Product",
            description="Created with betterproto",
            price=49.99
        )
    )
    
    print(f"\nCreated request for product: {request.product.name}")
    
    # Note: Betterproto generates async-first service clients
    # Example (would need actual server):
    # async with grpclib.client.Channel('localhost', 50051) as channel:
    #     service = ProductServiceClient(channel)
    #     response = await service.create_product(request)


def test_differences():
    """Highlight differences from standard protobuf."""
    print("\nBetterproto advantages:")
    print("1. Pythonic dataclasses with __init__")
    print("2. Snake_case field names")
    print("3. Async/await support built-in")
    print("4. Cleaner imports and structure")
    print("5. Better type hints")
    print("6. More intuitive API")
    
    print("\nConsiderations:")
    print("- Different from standard protobuf API")
    print("- May have performance differences")
    print("- Less ecosystem compatibility")


async def main():
    """Main async function."""
    print("Testing Betterproto Generation")
    print("=============================\n")
    
    await test_dataclasses()
    await test_service()
    test_differences()
    
    print("\n✓ Betterproto features working correctly!")


if __name__ == "__main__":
    asyncio.run(main())