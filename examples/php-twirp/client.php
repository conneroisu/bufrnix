<?php
// client.php
require_once 'vendor/autoload.php';

// Load mbstring polyfill if it exists
if (file_exists(__DIR__ . '/mbstring_polyfill.php')) {
    require_once __DIR__ . '/mbstring_polyfill.php';
}

use Example\Twirp\Example\V1\HelloRequest;
use Example\Twirp\Example\V1\HelloServiceClient;

$client = new HelloServiceClient('http://localhost:8080');

$request = new HelloRequest();
$request->setName("World");

try {
    $response = $client->Hello($request);
    echo $response->getGreeting() . "\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}