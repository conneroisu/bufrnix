package com.example

import com.example.protos.v1.*
import com.google.protobuf.util.JsonFormat

fun main() {
    println("Kotlin Protocol Buffers Example")
    println("==============================")
    
    // Create a new User using Kotlin DSL
    val user = user {
        id = "user-123"
        name = "John Doe"
        email = "john.doe@example.com"
        status = User.Status.ACTIVE
        
        // Add addresses
        addresses += address {
            street = "123 Main St"
            city = "Anytown"
            state = "CA"
            zipCode = "12345"
            country = "USA"
        }
        
        addresses += address {
            street = "456 Oak Ave"
            city = "Another City"
            state = "NY"
            zipCode = "67890"
            country = "USA"
        }
        
        // Set profile using oneof
        personal = personalProfile {
            dateOfBirth = "1990-01-01"
            hobbies += listOf("reading", "coding", "hiking")
        }
    }
    
    // Display the user
    println("\nCreated User:")
    println("  ID: ${user.id}")
    println("  Name: ${user.name}")
    println("  Email: ${user.email}")
    println("  Status: ${user.status}")
    println("  Addresses: ${user.addressesCount}")
    user.addressesList.forEachIndexed { index, addr ->
        println("    Address ${index + 1}: ${addr.street}, ${addr.city}, ${addr.state}")
    }
    
    when (user.profileCase) {
        User.ProfileCase.PERSONAL -> {
            println("  Personal Profile:")
            println("    DOB: ${user.personal.dateOfBirth}")
            println("    Hobbies: ${user.personal.hobbiesList.joinToString(", ")}")
        }
        User.ProfileCase.BUSINESS -> {
            println("  Business Profile:")
            println("    Company: ${user.business.companyName}")
        }
        else -> println("  No profile set")
    }
    
    // Serialize to bytes
    val bytes = user.toByteArray()
    println("\nSerialized to ${bytes.size} bytes")
    
    // Deserialize from bytes
    val deserializedUser = User.parseFrom(bytes)
    println("\nDeserialized user: ${deserializedUser.name}")
    
    // Create a UserList
    val userList = userList {
        users += user
        users += user {
            id = "user-456"
            name = "Jane Smith"
            email = "jane.smith@example.com"
            status = User.Status.ACTIVE
            
            business = businessProfile {
                companyName = "Tech Corp"
                position = "Senior Developer"
                department = "Engineering"
            }
        }
        totalCount = 2
    }
    
    // Convert to JSON
    val jsonPrinter = JsonFormat.printer()
        .includingDefaultValueFields()
        .preservingProtoFieldNames()
    
    val json = jsonPrinter.print(userList)
    println("\nUserList as JSON:")
    println(json)
    
    // Parse from JSON
    val jsonParser = JsonFormat.parser()
    val parsedUserList = UserList.newBuilder()
    jsonParser.merge(json, parsedUserList)
    
    println("\nParsed ${parsedUserList.build().usersCount} users from JSON")
    
    // Demonstrate Kotlin-specific features
    demonstrateKotlinFeatures()
}

fun demonstrateKotlinFeatures() {
    println("\n\nKotlin-Specific Features:")
    println("========================")
    
    // Using copy for immutable updates
    val original = user {
        id = "original"
        name = "Original User"
        email = "original@example.com"
    }
    
    val modified = original.copy {
        name = "Modified User"
        email = "modified@example.com"
    }
    
    println("Original: ${original.name} (${original.email})")
    println("Modified: ${modified.name} (${modified.email})")
    
    // Extension functions
    fun User.fullInfo(): String = "$name ($email) - Status: $status"
    
    println("\nUsing extension function: ${modified.fullInfo()}")
    
    // Collection operations
    val users = listOf(original, modified)
    val activeUsers = users.filter { it.status == User.Status.ACTIVE }
    println("\nActive users: ${activeUsers.size}")
    
    // Null safety with protobuf
    val maybeUser: User? = if (users.isNotEmpty()) users.first() else null
    maybeUser?.let {
        println("First user: ${it.name}")
    } ?: println("No users found")
}