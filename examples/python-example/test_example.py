#!/usr/bin/env python3
"""
Tests for the Python protobuf generation example.
"""

import time
import pytest
from proto.gen.python.example.v1 import example_pb2
from google.protobuf.json_format import MessageToJson, Parse


class TestGreetingMessage:
    """Test the generated Greeting message."""
    
    def test_create_greeting(self):
        """Test creating a basic greeting message."""
        greeting = example_pb2.Greeting(
            id="test-001",
            content="Test greeting",
            created_at=int(time.time())
        )
        
        assert greeting.id == "test-001"
        assert greeting.content == "Test greeting"
        assert greeting.created_at > 0
    
    def test_repeated_fields(self):
        """Test repeated fields (lists)."""
        greeting = example_pb2.Greeting()
        greeting.tags.extend(["tag1", "tag2", "tag3"])
        
        assert len(greeting.tags) == 3
        assert "tag2" in greeting.tags
        assert list(greeting.tags) == ["tag1", "tag2", "tag3"]
    
    def test_map_fields(self):
        """Test map fields (dictionaries)."""
        greeting = example_pb2.Greeting()
        greeting.metadata["key1"] = "value1"
        greeting.metadata["key2"] = "value2"
        
        assert len(greeting.metadata) == 2
        assert greeting.metadata["key1"] == "value1"
        assert dict(greeting.metadata) == {"key1": "value1", "key2": "value2"}
    
    def test_serialization(self):
        """Test binary serialization and deserialization."""
        original = example_pb2.Greeting(
            id="serialize-test",
            content="Serialization test",
            created_at=1234567890
        )
        original.tags.extend(["test", "serialize"])
        original.metadata["version"] = "1.0"
        
        # Serialize to bytes
        data = original.SerializeToString()
        assert isinstance(data, bytes)
        assert len(data) > 0
        
        # Deserialize from bytes
        restored = example_pb2.Greeting()
        restored.ParseFromString(data)
        
        assert restored.id == original.id
        assert restored.content == original.content
        assert restored.created_at == original.created_at
        assert list(restored.tags) == list(original.tags)
        assert dict(restored.metadata) == dict(original.metadata)
    
    def test_json_serialization(self):
        """Test JSON serialization and deserialization."""
        original = example_pb2.Greeting(
            id="json-test",
            content="JSON test",
            created_at=1234567890
        )
        
        # Convert to JSON
        json_str = MessageToJson(original)
        assert isinstance(json_str, str)
        assert "json-test" in json_str
        
        # Parse from JSON
        restored = Parse(json_str, example_pb2.Greeting())
        assert restored.id == original.id
        assert restored.content == original.content


class TestServiceMessages:
    """Test service request/response messages."""
    
    def test_create_greeting_request(self):
        """Test CreateGreetingRequest message."""
        request = example_pb2.CreateGreetingRequest(
            content="New greeting",
            tags=["tag1", "tag2"]
        )
        
        assert request.content == "New greeting"
        assert len(request.tags) == 2
    
    def test_create_greeting_response(self):
        """Test CreateGreetingResponse message."""
        greeting = example_pb2.Greeting(id="resp-001", content="Response")
        response = example_pb2.CreateGreetingResponse(greeting=greeting)
        
        assert response.greeting.id == "resp-001"
        assert response.greeting.content == "Response"
    
    def test_list_greetings_request(self):
        """Test ListGreetingsRequest pagination."""
        request = example_pb2.ListGreetingsRequest(
            page_size=10,
            page_token="next-page"
        )
        
        assert request.page_size == 10
        assert request.page_token == "next-page"
    
    def test_list_greetings_response(self):
        """Test ListGreetingsResponse with multiple greetings."""
        response = example_pb2.ListGreetingsResponse(
            next_page_token="token-123"
        )
        
        # Add multiple greetings
        for i in range(3):
            greeting = example_pb2.Greeting(
                id=f"list-{i}",
                content=f"Greeting {i}"
            )
            response.greetings.append(greeting)
        
        assert len(response.greetings) == 3
        assert response.next_page_token == "token-123"
        assert response.greetings[1].id == "list-1"


class TestFieldTypes:
    """Test various protobuf field types."""
    
    def test_default_values(self):
        """Test default values for different field types."""
        greeting = example_pb2.Greeting()
        
        assert greeting.id == ""  # string default
        assert greeting.content == ""  # string default
        assert greeting.created_at == 0  # int64 default
        assert len(greeting.tags) == 0  # repeated field default
        assert len(greeting.metadata) == 0  # map field default
    
    def test_field_presence(self):
        """Test field presence checks."""
        greeting1 = example_pb2.Greeting()
        greeting2 = example_pb2.Greeting(id="has-id")
        
        # Both have the field (proto3 always has fields)
        assert hasattr(greeting1, "id")
        assert hasattr(greeting2, "id")
        
        # But values differ
        assert greeting1.id == ""
        assert greeting2.id == "has-id"
    
    def test_clear_fields(self):
        """Test clearing field values."""
        greeting = example_pb2.Greeting(
            id="clear-test",
            content="Will be cleared"
        )
        greeting.tags.extend(["tag1", "tag2"])
        
        # Clear specific fields
        greeting.ClearField("content")
        assert greeting.content == ""
        
        # Clear repeated field
        del greeting.tags[:]
        assert len(greeting.tags) == 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])