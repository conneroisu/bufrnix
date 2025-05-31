<?php

namespace App\Services;

use Example\V1\HelloRequest;
use Example\V1\HelloResponse;
use Example\V1\GreeterServiceInterface;
use Spiral\RoadRunner\GRPC\ContextInterface;

class GreeterService implements GreeterServiceInterface
{
    /**
     * Simple unary RPC implementation
     */
    public function SayHello(
        ContextInterface $ctx,
        HelloRequest $request
    ): HelloResponse {
        $response = new HelloResponse();
        $response->setMessage(sprintf(
            "Hello, %s! This is Bufrnix with PHP gRPC + RoadRunner",
            $request->getName()
        ));
        $response->setTimestamp(time());
        $response->setSuccess(true);
        
        // Access metadata if provided
        $metadata = $request->getMetadata();
        if ($metadata && $metadata->count() > 0) {
            $metaStr = [];
            foreach ($metadata as $key => $value) {
                $metaStr[] = "$key=$value";
            }
            $response->setMessage($response->getMessage() . " [" . implode(", ", $metaStr) . "]");
        }
        
        return $response;
    }
    
    /**
     * Server streaming RPC - sends multiple responses
     */
    public function SayHelloStream(
        ContextInterface $ctx,
        HelloRequest $request
    ): \Generator {
        $count = $request->getCount() ?: 5;
        
        for ($i = 1; $i <= $count; $i++) {
            $response = new HelloResponse();
            $response->setMessage(sprintf(
                "Hello #%d, %s! (Streaming from RoadRunner)",
                $i,
                $request->getName()
            ));
            $response->setTimestamp(time());
            $response->setSuccess(true);
            
            yield $response;
            
            // Simulate some work
            usleep(500000); // 500ms delay between messages
        }
    }
    
    /**
     * Client streaming RPC - receives multiple requests, sends single response
     */
    public function SayHelloClientStream(
        ContextInterface $ctx,
        \Iterator $requests
    ): HelloResponse {
        $names = [];
        $totalCount = 0;
        
        foreach ($requests as $request) {
            $names[] = $request->getName();
            $totalCount++;
        }
        
        $response = new HelloResponse();
        $response->setMessage(sprintf(
            "Hello to all %d of you: %s!",
            $totalCount,
            implode(", ", $names)
        ));
        $response->setTimestamp(time());
        $response->setSuccess(true);
        
        return $response;
    }
    
    /**
     * Bidirectional streaming RPC - ping-pong style communication
     */
    public function SayHelloBidirectional(
        ContextInterface $ctx,
        \Iterator $requests
    ): \Generator {
        foreach ($requests as $request) {
            $response = new HelloResponse();
            $response->setMessage(sprintf(
                "Echo back: Hello, %s! (Bidirectional stream)",
                $request->getName()
            ));
            $response->setTimestamp(time());
            $response->setSuccess(true);
            
            yield $response;
        }
    }
}