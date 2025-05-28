#include <iostream>
#include <memory>
#include <string>
#include <thread>
#include <chrono>

#include <grpcpp/grpcpp.h>
#include <google/protobuf/util/time_util.h>
#include "example/v1/greeter.grpc.pb.h"

using grpc::Channel;
using grpc::ClientContext;
using grpc::ClientReader;
using grpc::ClientWriter;
using grpc::ClientReaderWriter;
using grpc::Status;

using example::v1::GreeterService;
using example::v1::HelloRequest;
using example::v1::HelloResponse;
using google::protobuf::util::TimeUtil;

class GreeterClient {
public:
    GreeterClient(std::shared_ptr<Channel> channel)
        : stub_(GreeterService::NewStub(channel)) {}

    // Unary RPC
    std::string SayHello(const std::string& name, const std::string& language = "en") {
        HelloRequest request;
        request.set_name(name);
        request.set_language(language);
        *request.mutable_timestamp() = TimeUtil::GetCurrentTime();

        HelloResponse response;
        ClientContext context;

        Status status = stub_->SayHello(&context, request, &response);

        if (status.ok()) {
            std::cout << "Server response: " << response.message() << std::endl;
            std::cout << "Server timestamp: " << TimeUtil::ToString(response.server_timestamp()) << std::endl;
            return response.message();
        } else {
            std::cout << status.error_code() << ": " << status.error_message() << std::endl;
            return "RPC failed";
        }
    }

    // Server streaming RPC
    void SayHelloStream(const std::string& name) {
        HelloRequest request;
        request.set_name(name);
        request.set_language("en");
        *request.mutable_timestamp() = TimeUtil::GetCurrentTime();

        ClientContext context;
        std::unique_ptr<ClientReader<HelloResponse>> reader(
            stub_->SayHelloStream(&context, request));

        HelloResponse response;
        std::cout << "Starting server stream for: " << name << std::endl;
        
        while (reader->Read(&response)) {
            std::cout << "Stream response #" << response.response_count() 
                      << ": " << response.message() << std::endl;
        }

        Status status = reader->Finish();
        if (!status.ok()) {
            std::cout << "Stream RPC failed: " << status.error_message() << std::endl;
        }
    }

    // Client streaming RPC
    void SayHelloClientStream() {
        ClientContext context;
        HelloResponse response;
        std::unique_ptr<ClientWriter<HelloRequest>> writer(
            stub_->SayHelloClientStream(&context, &response));

        std::vector<std::string> names = {"Alice", "Bob", "Charlie", "Diana"};
        
        std::cout << "Starting client stream..." << std::endl;
        for (const auto& name : names) {
            HelloRequest request;
            request.set_name(name);
            request.set_language("en");
            *request.mutable_timestamp() = TimeUtil::GetCurrentTime();
            
            if (!writer->Write(request)) {
                break;
            }
            std::cout << "Sent: " << name << std::endl;
            std::this_thread::sleep_for(std::chrono::milliseconds(200));
        }

        writer->WritesDone();
        Status status = writer->Finish();

        if (status.ok()) {
            std::cout << "Client stream response: " << response.message() << std::endl;
        } else {
            std::cout << "Client stream RPC failed: " << status.error_message() << std::endl;
        }
    }

    // Bidirectional streaming RPC
    void SayHelloBidi() {
        ClientContext context;
        std::unique_ptr<ClientReaderWriter<HelloRequest, HelloResponse>> stream(
            stub_->SayHelloBidi(&context));

        std::vector<std::string> names = {"Eve", "Frank", "Grace"};
        
        // Start a thread to send requests
        std::thread writer([&stream, &names]() {
            for (const auto& name : names) {
                HelloRequest request;
                request.set_name(name);
                request.set_language("en");
                *request.mutable_timestamp() = TimeUtil::GetCurrentTime();
                
                if (!stream->Write(request)) {
                    break;
                }
                std::cout << "Bidi sent: " << name << std::endl;
                std::this_thread::sleep_for(std::chrono::milliseconds(300));
            }
            stream->WritesDone();
        });

        // Read responses
        HelloResponse response;
        while (stream->Read(&response)) {
            std::cout << "Bidi received: " << response.message() << std::endl;
        }

        writer.join();
        Status status = stream->Finish();
        if (!status.ok()) {
            std::cout << "Bidi RPC failed: " << status.error_message() << std::endl;
        }
    }

private:
    std::unique_ptr<GreeterService::Stub> stub_;
};

int main(int argc, char** argv) {
    GOOGLE_PROTOBUF_VERIFY_VERSION;

    std::string target_str = "localhost:50051";
    if (argc > 1) {
        target_str = argv[1];
    }

    // Create a channel to the server
    GreeterClient greeter(grpc::CreateChannel(
        target_str, grpc::InsecureChannelCredentials()));

    std::cout << "gRPC Greeter Client connecting to: " << target_str << std::endl;
    std::cout << "==========================================" << std::endl;

    // Test unary RPC
    std::cout << "\n1. Testing Unary RPC:" << std::endl;
    greeter.SayHello("World");
    greeter.SayHello("Mundo", "es");
    greeter.SayHello("Monde", "fr");

    // Test server streaming RPC
    std::cout << "\n2. Testing Server Streaming RPC:" << std::endl;
    greeter.SayHelloStream("StreamUser");

    // Test client streaming RPC
    std::cout << "\n3. Testing Client Streaming RPC:" << std::endl;
    greeter.SayHelloClientStream();

    // Test bidirectional streaming RPC
    std::cout << "\n4. Testing Bidirectional Streaming RPC:" << std::endl;
    greeter.SayHelloBidi();

    std::cout << "\nAll tests completed!" << std::endl;

    google::protobuf::ShutdownProtobufLibrary();
    return 0;
}