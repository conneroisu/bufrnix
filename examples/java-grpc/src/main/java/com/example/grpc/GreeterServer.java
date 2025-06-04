package com.example.grpc;

import com.example.grpc.v1.GreeterServiceGrpc;
import com.example.grpc.v1.HelloRequest;
import com.example.grpc.v1.HelloResponse;

import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.stub.StreamObserver;

import java.io.IOException;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

/**
 * Server implementation that uses the generated gRPC service stubs.
 * This demonstrates a working gRPC server using the Bufrnix-generated code.
 */
public class GreeterServer {
    private static final Logger logger = Logger.getLogger(GreeterServer.class.getName());
    
    private final int port;
    private final Server server;

    public GreeterServer(int port) {
        this.port = port;
        this.server = ServerBuilder.forPort(port)
            .addService(new GreeterServiceImpl())
            .build();
    }

    /** Start serving requests. */
    public void start() throws IOException {
        server.start();
        logger.info("Server started, listening on " + port);
        
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.err.println("*** shutting down gRPC server since JVM is shutting down");
            try {
                GreeterServer.this.stop();
            } catch (InterruptedException e) {
                e.printStackTrace(System.err);
            }
            System.err.println("*** server shut down");
        }));
    }

    /** Stop serving requests and shutdown resources. */
    public void stop() throws InterruptedException {
        if (server != null) {
            server.shutdown().awaitTermination(30, TimeUnit.SECONDS);
        }
    }

    /**
     * Await termination on the main thread since the grpc library uses daemon threads.
     */
    private void blockUntilShutdown() throws InterruptedException {
        if (server != null) {
            server.awaitTermination();
        }
    }

    /**
     * Implementation of the GreeterService using the generated gRPC stubs.
     */
    static class GreeterServiceImpl extends GreeterServiceGrpc.GreeterServiceImplBase {

        @Override
        public void sayHello(HelloRequest request, StreamObserver<HelloResponse> responseObserver) {
            String greeting = "Hello ";
            if (request.hasTitle()) {
                greeting += request.getTitle() + " ";
            }
            greeting += request.getName() + "!";

            HelloResponse response = HelloResponse.newBuilder()
                .setMessage(greeting)
                .setTimestamp(System.currentTimeMillis())
                .build();

            logger.info("Responding to sayHello: " + greeting);
            responseObserver.onNext(response);
            responseObserver.onCompleted();
        }

        @Override
        public void sayHelloStream(HelloRequest request, StreamObserver<HelloResponse> responseObserver) {
            String baseName = request.getName();
            if (request.hasTitle()) {
                baseName = request.getTitle() + " " + baseName;
            }

            // Send multiple greetings (server streaming)
            for (int i = 1; i <= 5; i++) {
                HelloResponse response = HelloResponse.newBuilder()
                    .setMessage("Hello " + baseName + " (message " + i + ")")
                    .setTimestamp(System.currentTimeMillis())
                    .build();

                logger.info("Streaming response " + i + ": " + response.getMessage());
                responseObserver.onNext(response);

                // Add a small delay between messages
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
            responseObserver.onCompleted();
        }

        @Override
        public StreamObserver<HelloRequest> sayHelloClientStream(StreamObserver<HelloResponse> responseObserver) {
            return new StreamObserver<HelloRequest>() {
                private StringBuilder names = new StringBuilder();
                private int count = 0;

                @Override
                public void onNext(HelloRequest request) {
                    count++;
                    if (names.length() > 0) {
                        names.append(", ");
                    }
                    if (request.hasTitle()) {
                        names.append(request.getTitle()).append(" ");
                    }
                    names.append(request.getName());
                    logger.info("Received client stream message " + count + ": " + request.getName());
                }

                @Override
                public void onError(Throwable t) {
                    logger.warning("sayHelloClientStream error: " + t.getMessage());
                }

                @Override
                public void onCompleted() {
                    HelloResponse response = HelloResponse.newBuilder()
                        .setMessage("Hello to all " + count + " people: " + names.toString())
                        .setTimestamp(System.currentTimeMillis())
                        .build();
                    
                    logger.info("Client stream completed. Responding: " + response.getMessage());
                    responseObserver.onNext(response);
                    responseObserver.onCompleted();
                }
            };
        }

        @Override
        public StreamObserver<HelloRequest> sayHelloBidirectional(StreamObserver<HelloResponse> responseObserver) {
            return new StreamObserver<HelloRequest>() {
                @Override
                public void onNext(HelloRequest request) {
                    String greeting = "Echo: Hello ";
                    if (request.hasTitle()) {
                        greeting += request.getTitle() + " ";
                    }
                    greeting += request.getName() + "!";

                    HelloResponse response = HelloResponse.newBuilder()
                        .setMessage(greeting)
                        .setTimestamp(System.currentTimeMillis())
                        .build();

                    logger.info("Bidirectional response: " + greeting);
                    responseObserver.onNext(response);
                }

                @Override
                public void onError(Throwable t) {
                    logger.warning("sayHelloBidirectional error: " + t.getMessage());
                }

                @Override
                public void onCompleted() {
                    logger.info("Bidirectional stream completed");
                    responseObserver.onCompleted();
                }
            };
        }
    }

    /**
     * Main method to start the server.
     */
    public static void main(String[] args) throws IOException, InterruptedException {
        logger.info("Starting gRPC GreeterServer using Bufrnix-generated stubs...");
        
        GreeterServer server = new GreeterServer(8980);
        server.start();
        
        logger.info("Server is running. Available services:");
        logger.info("  - sayHello (unary RPC)");
        logger.info("  - sayHelloStream (server streaming RPC)");
        logger.info("  - sayHelloClientStream (client streaming RPC)");
        logger.info("  - sayHelloBidirectional (bidirectional streaming RPC)");
        logger.info("");
        logger.info("Connect with GreeterClient or any gRPC client on port 8980");
        logger.info("Press Ctrl+C to stop the server");
        
        server.blockUntilShutdown();
    }
}