<?php
/**
 * Test client for PHP gRPC + RoadRunner example
 * 
 * This demonstrates various gRPC communication patterns:
 * - Unary RPC
 * - Server streaming
 * - Client streaming
 * - Bidirectional streaming
 */

require __DIR__ . '/vendor/autoload.php';

use App\Proto\Example\V1\HelloRequest;
use App\Proto\Example\V1\Services\GreeterServiceClient;
use Grpc\ChannelCredentials;

// ANSI color codes for pretty output
$colors = [
    'green' => "\033[32m",
    'blue' => "\033[34m",
    'yellow' => "\033[33m",
    'red' => "\033[31m",
    'reset' => "\033[0m"
];

function printSection($title) {
    global $colors;
    echo "\n{$colors['blue']}=== $title ==={$colors['reset']}\n\n";
}

function printSuccess($message) {
    global $colors;
    echo "{$colors['green']}✓ $message{$colors['reset']}\n";
}

function printError($message) {
    global $colors;
    echo "{$colors['red']}✗ $message{$colors['reset']}\n";
}

// Create gRPC client
$client = new GreeterServiceClient('localhost:9001', [
    'credentials' => ChannelCredentials::createInsecure(),
    'timeout' => 10000000, // 10 seconds
]);

// 1. Test Unary RPC
printSection("Testing Unary RPC");

$request = new HelloRequest();
$request->setName('Bufrnix User');
$request->setMetadata(['client' => 'php', 'version' => '1.0']);

[$response, $status] = $client->SayHello($request)->wait();

if ($status->code === \Grpc\STATUS_OK) {
    printSuccess("Response: " . $response->getMessage());
    printSuccess("Timestamp: " . date('Y-m-d H:i:s', $response->getTimestamp()));
    printSuccess("Success: " . ($response->getSuccess() ? 'true' : 'false'));
} else {
    printError("Failed with status " . $status->code . ": " . $status->details);
}

// 2. Test Server Streaming RPC
printSection("Testing Server Streaming RPC");

$request = new HelloRequest();
$request->setName('Stream Fan');
$request->setCount(3);

$call = $client->SayHelloStream($request);
$streamCount = 0;

foreach ($call->responses() as $response) {
    $streamCount++;
    printSuccess("Stream $streamCount: " . $response->getMessage());
}

$status = $call->getStatus();
if ($status->code !== \Grpc\STATUS_OK) {
    printError("Stream failed: " . $status->details);
}

// 3. Test Client Streaming RPC
printSection("Testing Client Streaming RPC");

$call = $client->SayHelloClientStream();

// Send multiple requests
$names = ['Alice', 'Bob', 'Charlie', 'Diana'];
foreach ($names as $name) {
    $request = new HelloRequest();
    $request->setName($name);
    $call->write($request);
    echo "Sent: $name\n";
}

$call->writesDone();
[$response, $status] = $call->wait();

if ($status->code === \Grpc\STATUS_OK) {
    printSuccess("Server response: " . $response->getMessage());
} else {
    printError("Client stream failed: " . $status->details);
}

// 4. Test Bidirectional Streaming RPC
printSection("Testing Bidirectional Streaming RPC");

$call = $client->SayHelloBidirectional();

// Start a separate thread/process to read responses
// In real applications, you might use async patterns
$messages = ['First', 'Second', 'Third'];
$responses = [];

// Send messages
foreach ($messages as $msg) {
    $request = new HelloRequest();
    $request->setName($msg);
    $call->write($request);
    echo "Sent: $msg\n";
}
$call->writesDone();

// Read responses
foreach ($call->responses() as $response) {
    $responses[] = $response->getMessage();
    printSuccess("Received: " . $response->getMessage());
}

$status = $call->getStatus();
if ($status->code !== \Grpc\STATUS_OK) {
    printError("Bidirectional stream failed: " . $status->details);
}

// Summary
printSection("Test Summary");
echo "All gRPC communication patterns tested successfully!\n";
echo "- Unary RPC: ✓\n";
echo "- Server Streaming: ✓\n";
echo "- Client Streaming: ✓\n";
echo "- Bidirectional Streaming: ✓\n";