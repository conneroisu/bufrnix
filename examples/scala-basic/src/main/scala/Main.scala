package com.example.protobuf

import com.example.protobuf.v1.person._
import java.nio.file.{Files, Paths}

object Main extends App {
  println("Scala Protocol Buffer Example")
  println("=============================")
  
  // Create a person with an address and phone numbers
  val john = Person(
    id = 1,
    name = "John Doe",
    email = "john.doe@example.com",
    phones = Seq(
      PhoneNumber(
        number = "+1-555-0123",
        `type` = PhoneType.PHONE_TYPE_MOBILE
      ),
      PhoneNumber(
        number = "+1-555-0124",
        `type` = PhoneType.PHONE_TYPE_WORK
      )
    ),
    address = Some(Address(
      street = "123 Main St",
      city = "Springfield",
      state = "IL",
      zip = "62701",
      country = "USA"
    ))
  )
  
  // Create another person
  val jane = Person(
    id = 2,
    name = "Jane Smith",
    email = "jane.smith@example.com",
    phones = Seq(
      PhoneNumber(
        number = "+1-555-0125",
        `type` = PhoneType.PHONE_TYPE_HOME
      )
    )
  )
  
  // Create an address book
  val addressBook = AddressBook(
    people = Seq(john, jane)
  )
  
  // Display the address book
  println("\nAddress Book Contents:")
  addressBook.people.foreach { person =>
    println(s"\nPerson ID: ${person.id}")
    println(s"Name: ${person.name}")
    println(s"Email: ${person.email}")
    
    if (person.phones.nonEmpty) {
      println("Phone Numbers:")
      person.phones.foreach { phone =>
        val phoneType = phone.`type` match {
          case PhoneType.PHONE_TYPE_MOBILE => "Mobile"
          case PhoneType.PHONE_TYPE_HOME => "Home"
          case PhoneType.PHONE_TYPE_WORK => "Work"
          case _ => "Unknown"
        }
        println(s"  $phoneType: ${phone.number}")
      }
    }
    
    person.address.foreach { addr =>
      println("Address:")
      println(s"  ${addr.street}")
      println(s"  ${addr.city}, ${addr.state} ${addr.zip}")
      println(s"  ${addr.country}")
    }
  }
  
  // Serialize to binary
  println("\n\nSerializing to binary...")
  val bytes = addressBook.toByteArray
  println(s"Serialized size: ${bytes.length} bytes")
  
  // Save to file
  val outputPath = Paths.get("addressbook.pb")
  Files.write(outputPath, bytes)
  println(s"Saved to: ${outputPath.toAbsolutePath}")
  
  // Deserialize from binary
  println("\nDeserializing from binary...")
  val loadedBytes = Files.readAllBytes(outputPath)
  val loadedAddressBook = AddressBook.parseFrom(loadedBytes)
  
  println(s"Loaded ${loadedAddressBook.people.length} people from file")
  
  // Verify the data matches
  val dataMatches = addressBook == loadedAddressBook
  println(s"Data integrity check: ${if (dataMatches) "PASSED" else "FAILED"}")
  
  // Demonstrate updating a message
  println("\n\nDemonstrating message updates...")
  val updatedJohn = john.copy(
    email = "john.doe@newdomain.com",
    phones = john.phones :+ PhoneNumber(
      number = "+1-555-0126",
      `type` = PhoneType.PHONE_TYPE_HOME
    )
  )
  
  println(s"Updated email: ${updatedJohn.email}")
  println(s"Total phone numbers: ${updatedJohn.phones.length}")
  
  // Clean up
  Files.deleteIfExists(outputPath)
  println("\nExample completed successfully!")
}