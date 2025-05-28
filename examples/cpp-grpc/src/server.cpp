#include <iostream>
#include <memory>
#include <string>
#include <thread>
#include <chrono>

#include <grpcpp/grpcpp.h>
#include <google/protobuf/util/time_util.h>
#include "example/v1/greeter.grpc.pb.h"

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::ServerReader;
using grpc::ServerWriter;
using grpc::ServerReaderWriter;
using grpc::Status;

using example::v1::GreeterService;
using example::v1::HelloRequest;
using example::v1::HelloResponse;
using google::protobuf::util::TimeUtil;

class GreeterServiceImpl final : public GreeterService::Service {
public:
    // Simple unary RPC
    Status SayHello(ServerContext* context, 
                   const HelloRequest* request,
                   HelloResponse* response) override {
        std::cout << "Received request from: " << request->name() 
                  << " (language: " << request->language() << ")" << std::endl;
        
        std::string greeting;
        if (request->language() == "es") {
            greeting = "¡Hola, " + request->name() + "!";
        } else if (request->language() == "fr") {
            greeting = "Bonjour, " + request->name() + "!";
        } else if (request->language() == "de") {
            greeting = "Hallo, " + request->name() + "!";
        } else {
            greeting = "Hello, " + request->name() + "!";
        }
        
        response->set_message(greeting);
        response->set_language(request->language());
        *response->mutable_server_timestamp() = TimeUtil::GetCurrentTime();
        response->set_response_count(1);
        
        return Status::OK;
    }

    // Server streaming RPC
    Status SayHelloStream(ServerContext* context,
                         const HelloRequest* request,
                         ServerWriter<HelloResponse>* writer) override {
        std::cout << "Starting stream for: " << request->name() << std::endl;
        
        for (int i = 1; i <= 5; ++i) {
            HelloResponse response;
            response.set_message("Hello #" + std::to_string(i) + ", " + request->name() + "!");
            response.set_language(request->language());
            *response.mutable_server_timestamp() = TimeUtil::GetCurrentTime();
            response.set_response_count(i);
            
            if (!writer->Write(response)) {
                // Client disconnected
                break;
            }
            
            // Simulate some processing time
            std::this_thread::sleep_for(std::chrono::milliseconds(500));
        }
        
        return Status::OK;
    }

    // Client streaming RPC
    Status SayHelloClientStream(ServerContext* context,
                               ServerReader<HelloRequest>* reader,
                               HelloResponse* response) override {
        HelloRequest request;
        std::vector<std::string> names;
        
        // Read all requests from client
        while (reader->Read(&request)) {
            names.push_back(request.name());
            std::cout << "Received name: " << request.name() << std::endl;
        }
        
        // Send single response with all names
        std::string all_names;
        for (size_t i = 0; i < names.size(); ++i) {
            if (i > 0) all_names += ", ";
            all_names += names[i];
        }
        
        response->set_message("Hello to all: " + all_names + "!");
        response->set_language("en");
        *response->mutable_server_timestamp() = TimeUtil::GetCurrentTime();
        response->set_response_count(static_cast<int32_t>(names.size()));
        
        return Status::OK;
    }

    // Bidirectional streaming RPC
    Status SayHelloBidi(ServerContext* context,
                       ServerReaderWriter<HelloResponse, HelloRequest>* stream) override {
        HelloRequest request;
        int count = 0;
        
        while (stream->Read(&request)) {
            ++count;
            std::cout << "Bidi stream - received: " << request.name() << std::endl;
            
            HelloResponse response;
            response.set_message("Bidi hello #" + std::to_string(count) + ", " + request.name() + "!");
            response.set_language(request.language());
            *response.mutable_server_timestamp() = TimeUtil::GetCurrentTime();
            response.set_response_count(count);
            
            if (!stream->Write(response)) {
                break;
            }
        }
        
        return Status::OK;
    }
};

void RunServer() {
    std::string server_address("0.0.0.0:50051");
    GreeterServiceImpl service;

    ServerBuilder builder;
    // Listen on the given address without any authentication mechanism.
    builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
    // Register "service" as the instance through which we'll communicate with
    // clients. In this case it corresponds to an *synchronous* service.
    builder.RegisterService(&service);
    
    // Finally assemble the server.
    std::unique_ptr<Server> server(builder.BuildAndStart());
    std::cout << "Server listening on " << server_address << std::endl;
    std::cout << "Server supports:" << std::endl;
    std::cout << "  - Unary RPC (SayHello)" << std::endl;
    std::cout << "  - Server streaming (SayHelloStream)" << std::endl;
    std::cout << "  - Client streaming (SayHelloClientStream)" << std::endl;
    std::cout << "  - Bidirectional streaming (SayHelloBidi)" << std::endl;

    // Wait for the server to shutdown. Note that some other thread must be
    // responsible for shutting down the server for this call to ever return.
    server->Wait();
}

int main(int argc, char** argv) {
    // Verify that the version of the library that we linked against is
    // compatible with the version of the headers we compiled against.
    GOOGLE_PROTOBUF_VERIFY_VERSION;
    
    std::cout << "Starting gRPC Greeter Server..." << std::endl;
    RunServer();

    google::protobuf::ShutdownProtobufLibrary();
    return 0;
}