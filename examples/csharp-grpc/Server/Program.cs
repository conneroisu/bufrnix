using Grpc.Core;
using GreeterProtos.Example.V1;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using System.Threading.Tasks;

var builder = WebApplication.CreateBuilder(args);

// Configure Kestrel for HTTP/2
builder.Services.Configure<Microsoft.AspNetCore.Server.Kestrel.Core.KestrelServerOptions>(options =>
{
    options.ConfigureEndpointDefaults(lo => lo.Protocols = Microsoft.AspNetCore.Server.Kestrel.Core.HttpProtocols.Http2);
});

// Add gRPC services
builder.Services.AddGrpc();

var app = builder.Build();

// Map gRPC service
app.MapGrpcService<GreeterService>();

app.MapGet("/", () => "Communication with gRPC endpoints must be made through a gRPC client.");

app.Run();

public class GreeterService : Greeter.GreeterBase
{
    private readonly ILogger<GreeterService> _logger;

    public GreeterService(ILogger<GreeterService> logger)
    {
        _logger = logger;
    }

    public override Task<HelloReply> SayHello(HelloRequest request, ServerCallContext context)
    {
        _logger.LogInformation($"Received request from: {request.Name}");
        
        return Task.FromResult(new HelloReply
        {
            Message = $"Hello {request.Name}! Welcome to gRPC with C# and Bufrnix!",
            Timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
        });
    }

    public override async Task SayHelloStream(HelloRequest request, IServerStreamWriter<HelloReply> responseStream, ServerCallContext context)
    {
        _logger.LogInformation($"Starting stream for: {request.Name}");
        
        for (int i = 0; i < 5; i++)
        {
            await responseStream.WriteAsync(new HelloReply
            {
                Message = $"Hello {request.Name}! Message #{i + 1}",
                Timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
            });
            
            await Task.Delay(1000); // Delay 1 second between messages
        }
    }

    public override async Task SayHelloToMany(IAsyncStreamReader<HelloRequest> requestStream, IServerStreamWriter<HelloReply> responseStream, ServerCallContext context)
    {
        await foreach (var request in requestStream.ReadAllAsync())
        {
            _logger.LogInformation($"Received: {request.Name}");
            
            await responseStream.WriteAsync(new HelloReply
            {
                Message = $"Hello {request.Name}! Thanks for joining the stream!",
                Timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
            });
        }
    }
}