#!/usr/bin/env python3
"""Test basic Python protobuf generation."""

import sys
sys.path.insert(0, '.')

from proto.gen.python import basic_pb2

def test_basic_protobuf():
    # Create a person
    person = basic_pb2.Person()
    person.name = "Alice"
    person.age = 30
    person.email = "alice@example.com"
    
    print(f"Created person: {person.name}, age {person.age}")
    
    # Create an address book
    address_book = basic_pb2.AddressBook()
    address_book.people.append(person)
    
    # Add another person
    bob = address_book.people.add()
    bob.name = "Bob"
    bob.age = 25
    bob.email = "bob@example.com"
    
    print(f"Address book has {len(address_book.people)} people")
    
    # Serialize and deserialize
    data = address_book.SerializeToString()
    print(f"Serialized size: {len(data)} bytes")
    
    # Deserialize
    new_book = basic_pb2.AddressBook()
    new_book.ParseFromString(data)
    
    print("Deserialized people:")
    for p in new_book.people:
        print(f"  - {p.name} ({p.age}): {p.email}")

if __name__ == "__main__":
    test_basic_protobuf()