package com.example.server

import com.example.grpc.v1.*
import io.grpc.Server
import io.grpc.ServerBuilder
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow
import java.util.concurrent.TimeUnit

class GreeterService : GreeterGrpcKt.GreeterCoroutineImplBase() {
    
    override suspend fun sayHello(request: HelloRequest): HelloReply {
        val greeting = when (request.language.lowercase()) {
            "spanish" -> "¡Hola ${request.name}!"
            "french" -> "Bonjour ${request.name}!"
            "german" -> "Hallo ${request.name}!"
            "kotlin" -> "println(\"Hello ${request.name}!\")"
            else -> "Hello ${request.name}!"
        }
        
        return helloReply {
            message = greeting
            timestamp = System.currentTimeMillis()
        }
    }
    
    override fun sayHelloStream(request: HelloRequest): Flow<HelloReply> = flow {
        val greetings = listOf(
            "Hello ${request.name}!",
            "Welcome ${request.name}!",
            "Greetings ${request.name}!",
            "Nice to meet you ${request.name}!",
            "How are you ${request.name}?"
        )
        
        for (greeting in greetings) {
            emit(helloReply {
                message = greeting
                timestamp = System.currentTimeMillis()
            })
            delay(1000) // Delay 1 second between messages
        }
    }
    
    override suspend fun sayHelloToMany(requests: Flow<HelloRequest>): HelloReply {
        val names = mutableListOf<String>()
        
        requests.collect { request ->
            names.add(request.name)
            println("Received: ${request.name}")
        }
        
        return helloReply {
            message = "Hello to all ${names.size} people: ${names.joinToString(", ")}!"
            timestamp = System.currentTimeMillis()
        }
    }
    
    override fun chat(requests: Flow<HelloRequest>): Flow<HelloReply> = flow {
        requests.collect { request ->
            val response = when {
                request.name.contains("bye", ignoreCase = true) -> 
                    "Goodbye ${request.name}! It was nice chatting!"
                request.name.contains("hello", ignoreCase = true) -> 
                    "Hello there! Nice to meet you!"
                else -> 
                    "You said: '${request.name}'"
            }
            
            emit(helloReply {
                message = response
                timestamp = System.currentTimeMillis()
            })
        }
    }
}

fun main() {
    val port = 50051
    val server: Server = ServerBuilder
        .forPort(port)
        .addService(GreeterService())
        .build()
    
    server.start()
    println("Kotlin gRPC Server started on port $port")
    println("Using coroutines for async handling")
    
    Runtime.getRuntime().addShutdownHook(Thread {
        println("Shutting down gRPC server...")
        server.shutdown()
        server.awaitTermination(30, TimeUnit.SECONDS)
    })
    
    server.awaitTermination()
}