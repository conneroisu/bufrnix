#!/usr/bin/env python3
"""Test script for the flake-parts Python example."""

import sys
import os

# Add current directory to path to find generated files
sys.path.insert(0, '.')

try:
    import gen.example.v1.user_pb2 as user_pb2
    import gen.example.v1.user_pb2_grpc as user_pb2_grpc
    from google.protobuf.timestamp_pb2 import Timestamp
    print("✓ Successfully imported generated protobuf modules")
except ImportError as e:
    print(f"❌ Failed to import generated protobuf modules: {e}")
    print("Make sure to run 'nix build' first to generate the proto files.")
    sys.exit(1)


def test_user_creation():
    """Test creating and manipulating User protobuf messages."""
    print("\n🔧 Testing User message creation...")
    
    # Create timestamp
    now = Timestamp()
    now.GetCurrentTime()
    
    # Create preferences
    preferences = user_pb2.UserPreferences(
        email_notifications=True,
        sms_notifications=False,
        language="en",
        timezone="UTC"
    )
    
    # Create user
    user = user_pb2.User(
        id="1",
        email="test@example.com",
        name="Test User",
        age=30,
        status=user_pb2.USER_STATUS_ACTIVE,
        created_at=now,
        updated_at=now,
        preferences=preferences
    )
    
    print(f"✓ Created user: {user.name}")
    print(f"  Email: {user.email}")
    print(f"  Age: {user.age}")
    print(f"  Status: {user_pb2.UserStatus.Name(user.status)}")
    
    # Test serialization
    serialized = user.SerializeToString()
    print(f"✓ Serialized to {len(serialized)} bytes")
    
    # Test deserialization
    new_user = user_pb2.User()
    new_user.ParseFromString(serialized)
    print(f"✓ Deserialized user: {new_user.name}")
    
    return user


def test_requests():
    """Test request/response messages."""
    print("\n📝 Testing request/response messages...")
    
    # Create user request
    preferences = user_pb2.UserPreferences(
        email_notifications=True,
        sms_notifications=True,
        language="es",
        timezone="America/New_York"
    )
    
    create_request = user_pb2.CreateUserRequest(
        email="john.doe@example.com",
        name="John Doe",
        age=25,
        preferences=preferences
    )
    
    print(f"✓ Created CreateUserRequest for: {create_request.name}")
    
    # Test list request
    list_request = user_pb2.ListUsersRequest(
        page_size=10,
        status_filter=user_pb2.USER_STATUS_ACTIVE
    )
    
    print(f"✓ Created ListUsersRequest with page_size: {list_request.page_size}")
    
    return create_request, list_request


def main():
    """Main test function."""
    print("🐍 Python flake-parts Bufrnix Example Test")
    print("=" * 50)
    
    try:
        user = test_user_creation()
        create_request, list_request = test_requests()
        
        print("\n🎉 All tests passed!")
        print("\nThis example demonstrates:")
        print("  • Flake-parts integration with Bufrnix")
        print("  • Python protobuf message generation")
        print("  • gRPC service stub generation")
        print("  • Message serialization/deserialization")
        print("  • Enum handling")
        print("  • Nested message structures")
        
    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()