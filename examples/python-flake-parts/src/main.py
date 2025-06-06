#!/usr/bin/env python3
"""
Python flake-parts example demonstrating Bufrnix-generated protobuf code.

This example shows how to use protobuf messages and gRPC services generated
by Bufrnix in a flake-parts environment.
"""

import sys
import os
from datetime import datetime
from typing import List

# Add the generated code to the Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

try:
    import gen.example.v1.user_pb2 as user_pb2
    import gen.example.v1.user_pb2_grpc as user_pb2_grpc
    from google.protobuf.timestamp_pb2 import Timestamp
except ImportError as e:
    print(f"❌ Failed to import generated protobuf modules: {e}")
    print("Make sure to run 'nix build' first to generate the proto files.")
    sys.exit(1)


class UserServiceDemo:
    """Demonstration of the generated User service and messages."""
    
    def __init__(self):
        self.users = {}
        self.next_id = 1
    
    def create_sample_user(self) -> user_pb2.User:
        """Create a sample user with all fields populated."""
        now = Timestamp()
        now.GetCurrentTime()
        
        preferences = user_pb2.UserPreferences(
            email_notifications=True,
            sms_notifications=False,
            language="en",
            timezone="UTC"
        )
        
        user = user_pb2.User(
            id=str(self.next_id),
            email=f"user{self.next_id}@example.com",
            name=f"User {self.next_id}",
            age=25 + (self.next_id % 50),
            status=user_pb2.USER_STATUS_ACTIVE,
            created_at=now,
            updated_at=now,
            preferences=preferences
        )
        
        self.users[user.id] = user
        self.next_id += 1
        return user
    
    def create_user(self, request: user_pb2.CreateUserRequest) -> user_pb2.CreateUserResponse:
        """Simulate creating a user."""
        now = Timestamp()
        now.GetCurrentTime()
        
        user = user_pb2.User(
            id=str(self.next_id),
            email=request.email,
            name=request.name,
            age=request.age,
            status=user_pb2.USER_STATUS_ACTIVE,
            created_at=now,
            updated_at=now,
            preferences=request.preferences
        )
        
        self.users[user.id] = user
        self.next_id += 1
        
        return user_pb2.CreateUserResponse(user=user)
    
    def get_user(self, request: user_pb2.GetUserRequest) -> user_pb2.GetUserResponse:
        """Simulate getting a user by ID."""
        user = self.users.get(request.id)
        return user_pb2.GetUserResponse(user=user)
    
    def list_users(self, request: user_pb2.ListUsersRequest) -> user_pb2.ListUsersResponse:
        """Simulate listing users with pagination."""
        all_users = list(self.users.values())
        
        # Filter by status if specified
        if request.status_filter != user_pb2.USER_STATUS_UNSPECIFIED:
            all_users = [u for u in all_users if u.status == request.status_filter]
        
        # Simple pagination simulation
        page_size = request.page_size if request.page_size > 0 else 10
        start_idx = 0
        
        if request.page_token:
            try:
                start_idx = int(request.page_token)
            except ValueError:
                start_idx = 0
        
        end_idx = start_idx + page_size
        page_users = all_users[start_idx:end_idx]
        
        next_token = str(end_idx) if end_idx < len(all_users) else ""
        
        return user_pb2.ListUsersResponse(
            users=page_users,
            next_page_token=next_token,
            total_count=len(all_users)
        )


def demonstrate_protobuf_usage():
    """Demonstrate various protobuf message operations."""
    print("🔧 Bufrnix Python flake-parts Example")
    print("=" * 50)
    
    service = UserServiceDemo()
    
    # Create some sample users
    print("\n📝 Creating sample users...")
    for i in range(3):
        user = service.create_sample_user()
        print(f"  ✓ Created user: {user.name} ({user.email})")
    
    # Demonstrate CreateUser request
    print("\n🆕 Creating user via CreateUserRequest...")
    preferences = user_pb2.UserPreferences(
        email_notifications=True,
        sms_notifications=True,
        language="es",
        timezone="America/New_York"
    )
    
    create_request = user_pb2.CreateUserRequest(
        email="john.doe@example.com",
        name="John Doe",
        age=30,
        preferences=preferences
    )
    
    create_response = service.create_user(create_request)
    print(f"  ✓ Created: {create_response.user.name} (ID: {create_response.user.id})")
    
    # Demonstrate GetUser request
    print("\n🔍 Getting user by ID...")
    get_request = user_pb2.GetUserRequest(id="1")
    get_response = service.get_user(get_request)
    
    if get_response.user.id:
        user = get_response.user
        print(f"  ✓ Found user: {user.name}")
        print(f"    Email: {user.email}")
        print(f"    Age: {user.age}")
        print(f"    Status: {user_pb2.UserStatus.Name(user.status)}")
        print(f"    Notifications: Email={user.preferences.email_notifications}, SMS={user.preferences.sms_notifications}")
    else:
        print("  ❌ User not found")
    
    # Demonstrate ListUsers request
    print("\n📋 Listing all users...")
    list_request = user_pb2.ListUsersRequest(
        page_size=10,
        status_filter=user_pb2.USER_STATUS_ACTIVE
    )
    
    list_response = service.list_users(list_request)
    print(f"  ✓ Found {len(list_response.users)} active users (total: {list_response.total_count})")
    
    for user in list_response.users:
        status_name = user_pb2.UserStatus.Name(user.status)
        print(f"    - {user.name} ({user.email}) - {status_name}")
    
    # Demonstrate enum usage
    print("\n🏷️  Demonstrating enum usage...")
    statuses = [
        user_pb2.USER_STATUS_ACTIVE,
        user_pb2.USER_STATUS_INACTIVE,
        user_pb2.USER_STATUS_SUSPENDED
    ]
    
    for status in statuses:
        status_name = user_pb2.UserStatus.Name(status)
        print(f"  Status {status}: {status_name}")
    
    # Demonstrate serialization/deserialization
    print("\n💾 Demonstrating serialization...")
    original_user = list_response.users[0] if list_response.users else None
    
    if original_user:
        # Serialize to bytes
        serialized = original_user.SerializeToString()
        print(f"  ✓ Serialized user to {len(serialized)} bytes")
        
        # Deserialize from bytes
        deserialized_user = user_pb2.User()
        deserialized_user.ParseFromString(serialized)
        print(f"  ✓ Deserialized user: {deserialized_user.name}")
        
        # Verify they're the same
        assert original_user.id == deserialized_user.id
        assert original_user.name == deserialized_user.name
        print("  ✓ Serialization roundtrip successful")


def main():
    """Main entry point for the example."""
    try:
        demonstrate_protobuf_usage()
        print("\n🎉 Example completed successfully!")
        print("\nThis demonstrates:")
        print("  • Flake-parts integration with Bufrnix")
        print("  • Generated Python protobuf messages")
        print("  • Generated gRPC service stubs")
        print("  • Message creation and manipulation")
        print("  • Enum handling")
        print("  • Serialization/deserialization")
        
    except Exception as e:
        print(f"\n❌ Error running example: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()