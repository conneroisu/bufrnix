<?php
// client.php
require_once 'vendor/autoload.php';

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