package com.example;

import com.example.protos.v1.Person;
import com.example.protos.v1.AddressBook;

public class Main {
    public static void main(String[] args) {
        // Create a person
        Person.PhoneNumber phoneNumber = Person.PhoneNumber.newBuilder()
            .setNumber("555-1234")
            .setType(Person.PhoneType.HOME)
            .build();
            
        Person person = Person.newBuilder()
            .setId(1)
            .setName("John Doe")
            .setEmail("john.doe@example.com")
            .addPhones(phoneNumber)
            .build();
            
        // Create an address book
        AddressBook addressBook = AddressBook.newBuilder()
            .addPeople(person)
            .build();
            
        System.out.println("Created person: " + person.getName());
        System.out.println("Email: " + person.getEmail());
        System.out.println("Phone: " + person.getPhones(0).getNumber() + " (" + person.getPhones(0).getType() + ")");
        System.out.println("Address book has " + addressBook.getPeopleCount() + " people");
        
        // Demonstrate serialization
        byte[] serialized = addressBook.toByteArray();
        System.out.println("Serialized size: " + serialized.length + " bytes");
        
        try {
            // Demonstrate deserialization
            AddressBook parsed = AddressBook.parseFrom(serialized);
            System.out.println("Parsed person name: " + parsed.getPeople(0).getName());
        } catch (Exception e) {
            System.err.println("Error parsing: " + e.getMessage());
        }
    }
}