package com.example.client

import com.example.grpc.v1.*
import io.grpc.ManagedChannel
import io.grpc.ManagedChannelBuilder
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import java.util.concurrent.TimeUnit

class GreeterClient(private val channel: ManagedChannel) {
    private val stub = GreeterGrpcKt.GreeterCoroutineStub(channel)
    
    suspend fun greet(name: String, language: String = "english") {
        val request = helloRequest {
            this.name = name
            this.language = language
        }
        
        val response = stub.sayHello(request)
        println("Response: ${response.message}")
        println("Timestamp: ${response.timestamp}")
    }
    
    suspend fun greetStream(name: String) {
        println("\nStreaming greetings for $name:")
        val request = helloRequest {
            this.name = name
        }
        
        stub.sayHelloStream(request).collect { response ->
            println("  Stream: ${response.message}")
        }
    }
    
    suspend fun greetMany(names: List<String>) {
        println("\nSending multiple names:")
        val requests = names.asFlow().map { name ->
            helloRequest {
                this.name = name
            }
        }
        
        val response = stub.sayHelloToMany(requests)
        println("Combined response: ${response.message}")
    }
    
    suspend fun chat() {
        println("\nStarting chat session:")
        val messages = listOf(
            "Hello server!",
            "How are you?",
            "I'm using Kotlin with gRPC",
            "This is pretty cool!",
            "Bye for now!"
        )
        
        val requests = flow {
            for (msg in messages) {
                println("Sending: $msg")
                emit(helloRequest { name = msg })
                delay(1500)
            }
        }
        
        stub.chat(requests).collect { response ->
            println("Server says: ${response.message}")
        }
    }
    
    fun shutdown() {
        channel.shutdown().awaitTermination(5, TimeUnit.SECONDS)
    }
}

fun main() = runBlocking {
    val channel = ManagedChannelBuilder
        .forAddress("localhost", 50051)
        .usePlaintext()
        .build()
    
    val client = GreeterClient(channel)
    
    try {
        println("Kotlin gRPC Client Example")
        println("=========================")
        
        // Example 1: Simple unary call
        println("\n1. Simple greeting:")
        client.greet("Kotlin User")
        client.greet("Usuario", "spanish")
        client.greet("Utilisateur", "french")
        client.greet("Developer", "kotlin")
        
        // Example 2: Server streaming
        println("\n2. Server streaming:")
        client.greetStream("Stream User")
        
        // Example 3: Client streaming
        println("\n3. Client streaming:")
        client.greetMany(listOf("Alice", "Bob", "Charlie", "Diana"))
        
        // Example 4: Bidirectional streaming
        println("\n4. Bidirectional streaming:")
        client.chat()
        
        println("\nAll examples completed!")
        
    } finally {
        client.shutdown()
    }
}