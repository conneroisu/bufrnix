#!/usr/bin/env python3
"""Test Python type stubs and mypy integration."""

import sys
sys.path.insert(0, '.')

from typing import List, Optional
from proto.gen.python import typed_pb2
from proto.gen.python import typed_pb2_grpc


def create_user(name: str, email: Optional[str] = None) -> typed_pb2.User:
    """Create a user with proper typing."""
    user = typed_pb2.User()
    user.id = f"user-{name.lower()}"
    user.name = name
    
    if email:
        user.email = email
    
    user.status = typed_pb2.Status.ACTIVE
    user.tags.extend(["new", "python"])
    user.metadata["created_by"] = "test_types.py"
    
    # Set oneof field
    user.discord = f"{name}#1234"
    
    return user


def process_users(users: List[typed_pb2.User]) -> None:
    """Process a list of users with type hints."""
    for user in users:
        # IDE should provide autocomplete for all fields
        print(f"User: {user.name} ({user.id})")
        print(f"  Status: {typed_pb2.Status.Name(user.status)}")
        print(f"  Tags: {', '.join(user.tags)}")
        
        # Type-safe access to optional field
        if user.HasField('email'):
            print(f"  Email: {user.email}")
        
        # Type-safe oneof access
        contact = user.WhichOneof('contact')
        if contact == 'phone':
            print(f"  Phone: {user.phone}")
        elif contact == 'discord':
            print(f"  Discord: {user.discord}")


def test_service_types() -> None:
    """Test service request/response types."""
    # Create request with proper typing
    request = typed_pb2.GetUserRequest()
    request.user_id = "user-123"
    
    # Create response
    response = typed_pb2.GetUserResponse()
    response.user.CopyFrom(create_user("Alice", "alice@example.com"))
    response.found = True
    
    # Type hints ensure we use correct types
    assert isinstance(response.user, typed_pb2.User)
    assert isinstance(response.found, bool)
    
    print(f"\nService test: Found user {response.user.name}")


def main() -> None:
    """Main function with return type annotation."""
    print("Testing Python Type Stubs")
    print("========================\n")
    
    # Create some users
    users: List[typed_pb2.User] = [
        create_user("Alice", "alice@example.com"),
        create_user("Bob"),
        create_user("Charlie", "charlie@example.com"),
    ]
    
    process_users(users)
    test_service_types()
    
    print("\n✓ Type annotations working correctly!")
    print("✓ Run 'mypy test_types.py' to verify type checking")


if __name__ == "__main__":
    main()