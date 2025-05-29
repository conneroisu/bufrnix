using Grpc.Core;
using Grpc.Net.Client;
using GreeterProtos.Example.V1;
using System;
using System.Threading.Tasks;

// Create a channel to the server
using var channel = GrpcChannel.ForAddress("http://localhost:5000");
var client = new Greeter.GreeterClient(channel);

Console.WriteLine("C# gRPC Client Example");
Console.WriteLine("=====================");

// Example 1: Simple unary call
Console.WriteLine("\n1. Simple greeting:");
var reply = await client.SayHelloAsync(new HelloRequest { Name = "Bufrnix User" });
Console.WriteLine($"   Response: {reply.Message}");
Console.WriteLine($"   Timestamp: {DateTimeOffset.FromUnixTimeSeconds(reply.Timestamp).LocalDateTime}");

// Example 2: Server streaming
Console.WriteLine("\n2. Server streaming:");
using var streamingCall = client.SayHelloStream(new HelloRequest { Name = "Stream User" });
await foreach (var response in streamingCall.ResponseStream.ReadAllAsync())
{
    Console.WriteLine($"   Stream message: {response.Message}");
}

// Example 3: Bidirectional streaming
Console.WriteLine("\n3. Bidirectional streaming:");
using var bidiCall = client.SayHelloToMany();

// Start a task to send requests
var sendTask = Task.Run(async () =>
{
    var names = new[] { "Alice", "Bob", "Charlie", "Diana", "Eve" };
    foreach (var name in names)
    {
        await bidiCall.RequestStream.WriteAsync(new HelloRequest { Name = name });
        await Task.Delay(500);
    }
    await bidiCall.RequestStream.CompleteAsync();
});

// Read responses
await foreach (var response in bidiCall.ResponseStream.ReadAllAsync())
{
    Console.WriteLine($"   Bidirectional response: {response.Message}");
}

await sendTask;

Console.WriteLine("\nDone!");