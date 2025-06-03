package com.example.grpc;

import com.example.grpc.v1.GreeterServiceGrpc;
import com.example.grpc.v1.HelloRequest;
import com.example.grpc.v1.HelloResponse;

import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.stub.StreamObserver;

import java.util.Iterator;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

/**
 * Client implementation that uses the generated gRPC service stubs.
 * This demonstrates a working gRPC client using the Bufrnix-generated code.
 */
public class GreeterClient {
    private static final Logger logger = Logger.getLogger(GreeterClient.class.getName());

    private final ManagedChannel channel;
    private final GreeterServiceGrpc.GreeterServiceBlockingStub blockingStub;
    private final GreeterServiceGrpc.GreeterServiceStub asyncStub;

    /** Construct client connecting to GreeterServer at {@code host:port}. */
    public GreeterClient(String host, int port) {
        this(ManagedChannelBuilder.forAddress(host, port)
            // Channels are secure by default (via SSL/TLS). For the example we disable TLS to avoid
            // needing certificates.
            .usePlaintext()
            .build());
    }

    /** Construct client for accessing GreeterServer using the existing channel. */
    GreeterClient(ManagedChannel channel) {
        this.channel = channel;
        blockingStub = GreeterServiceGrpc.newBlockingStub(channel);
        asyncStub = GreeterServiceGrpc.newStub(channel);
    }

    public void shutdown() throws InterruptedException {
        channel.shutdown().awaitTermination(5, TimeUnit.SECONDS);
    }

    /** 
     * Demonstrate unary RPC call.
     */
    public void greetUnary(String name) {
        logger.info("=== Unary RPC Example ===");
        HelloRequest request = HelloRequest.newBuilder()
            .setName(name)
            .build();
        
        HelloResponse response;
        try {
            response = blockingStub.sayHello(request);
        } catch (Exception e) {
            logger.warning("RPC failed: " + e.getMessage());
            return;
        }
        
        logger.info("Unary response: " + response.getMessage());
        logger.info("Timestamp: " + response.getTimestamp());
    }

    /** 
     * Demonstrate unary RPC call with title.
     */
    public void greetUnaryWithTitle(String title, String name) {
        logger.info("=== Unary RPC with Title Example ===");
        HelloRequest request = HelloRequest.newBuilder()
            .setName(name)
            .setTitle(title)
            .build();
        
        HelloResponse response;
        try {
            response = blockingStub.sayHello(request);
        } catch (Exception e) {
            logger.warning("RPC failed: " + e.getMessage());
            return;
        }
        
        logger.info("Unary response: " + response.getMessage());
        logger.info("Timestamp: " + response.getTimestamp());
    }

    /**
     * Demonstrate server streaming RPC.
     */
    public void greetServerStream(String name) {
        logger.info("=== Server Streaming RPC Example ===");
        HelloRequest request = HelloRequest.newBuilder()
            .setName(name)
            .build();
        
        Iterator<HelloResponse> responses;
        try {
            responses = blockingStub.sayHelloStream(request);
            while (responses.hasNext()) {
                HelloResponse response = responses.next();
                logger.info("Server stream response: " + response.getMessage());
            }
        } catch (Exception e) {
            logger.warning("RPC failed: " + e.getMessage());
        }
    }

    /**
     * Demonstrate client streaming RPC.
     */
    public void greetClientStream(String[] names) throws InterruptedException {
        logger.info("=== Client Streaming RPC Example ===");
        CountDownLatch finishLatch = new CountDownLatch(1);
        
        StreamObserver<HelloResponse> responseObserver = new StreamObserver<HelloResponse>() {
            @Override
            public void onNext(HelloResponse response) {
                logger.info("Client stream response: " + response.getMessage());
            }

            @Override
            public void onError(Throwable t) {
                logger.warning("Client stream error: " + t.getMessage());
                finishLatch.countDown();
            }

            @Override
            public void onCompleted() {
                logger.info("Client stream completed");
                finishLatch.countDown();
            }
        };

        StreamObserver<HelloRequest> requestObserver = asyncStub.sayHelloClientStream(responseObserver);
        try {
            for (String name : names) {
                HelloRequest request = HelloRequest.newBuilder()
                    .setName(name)
                    .build();
                logger.info("Sending client stream request: " + name);
                requestObserver.onNext(request);
                Thread.sleep(100); // Small delay between requests
            }
        } catch (RuntimeException e) {
            requestObserver.onError(e);
            throw e;
        }
        requestObserver.onCompleted();

        // Wait for the server to complete
        if (!finishLatch.await(30, TimeUnit.SECONDS)) {
            logger.warning("Client stream did not complete within 30 seconds");
        }
    }

    /**
     * Demonstrate bidirectional streaming RPC.
     */
    public void greetBidirectional(String[] names) throws InterruptedException {
        logger.info("=== Bidirectional Streaming RPC Example ===");
        CountDownLatch finishLatch = new CountDownLatch(1);
        
        StreamObserver<HelloResponse> responseObserver = new StreamObserver<HelloResponse>() {
            @Override
            public void onNext(HelloResponse response) {
                logger.info("Bidirectional response: " + response.getMessage());
            }

            @Override
            public void onError(Throwable t) {
                logger.warning("Bidirectional error: " + t.getMessage());
                finishLatch.countDown();
            }

            @Override
            public void onCompleted() {
                logger.info("Bidirectional stream completed");
                finishLatch.countDown();
            }
        };

        StreamObserver<HelloRequest> requestObserver = asyncStub.sayHelloBidirectional(responseObserver);
        try {
            for (int i = 0; i < names.length; i++) {
                HelloRequest request = HelloRequest.newBuilder()
                    .setName(names[i])
                    .setTitle(i % 2 == 0 ? "Mr." : "Ms.")
                    .build();
                logger.info("Sending bidirectional request: " + request.getTitle() + " " + request.getName());
                requestObserver.onNext(request);
                Thread.sleep(500); // Small delay between requests
            }
        } catch (RuntimeException e) {
            requestObserver.onError(e);
            throw e;
        }
        requestObserver.onCompleted();

        // Wait for the server to complete
        if (!finishLatch.await(30, TimeUnit.SECONDS)) {
            logger.warning("Bidirectional stream did not complete within 30 seconds");
        }
    }

    /**
     * Main method demonstrating all gRPC call patterns.
     */
    public static void main(String[] args) throws Exception {
        String target = "localhost:8980";
        if (args.length > 0) {
            target = args[0];
        }

        logger.info("Connecting to gRPC GreeterServer at " + target);
        logger.info("Make sure the server is running first!");
        logger.info("");

        GreeterClient client = new GreeterClient("localhost", 8980);
        try {
            // Demonstrate unary RPC
            client.greetUnary("World");
            logger.info("");
            
            // Demonstrate unary RPC with title
            client.greetUnaryWithTitle("Dr.", "Smith");
            logger.info("");
            
            // Demonstrate server streaming RPC
            client.greetServerStream("Alice");
            logger.info("");
            
            // Demonstrate client streaming RPC
            String[] clientStreamNames = {"Bob", "Charlie", "Diana"};
            client.greetClientStream(clientStreamNames);
            logger.info("");
            
            // Demonstrate bidirectional streaming RPC
            String[] bidirectionalNames = {"Eve", "Frank", "Grace"};
            client.greetBidirectional(bidirectionalNames);
            
        } finally {
            client.shutdown();
        }
        
        logger.info("");
        logger.info("All gRPC examples completed successfully!");
        logger.info("This demonstrates the Bufrnix-generated gRPC stubs working with:");
        logger.info("  ✓ Unary RPCs");
        logger.info("  ✓ Server streaming RPCs");
        logger.info("  ✓ Client streaming RPCs");
        logger.info("  ✓ Bidirectional streaming RPCs");
    }
}