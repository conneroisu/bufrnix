<?php
// server.php
require_once 'vendor/autoload.php';

use Example\Twirp\Example\V1\HelloRequest;
use Example\Twirp\Example\V1\HelloResponse;
use Example\Twirp\Example\V1\HelloServiceInterface;

class HelloServiceImpl implements HelloServiceInterface {
    public function Hello(HelloRequest $request): HelloResponse {
        $response = new HelloResponse();
        $response->setGreeting("Hello, " . $request->getName() . "!");
        return $response;
    }
}

// Create and run the server
$addr = '127.0.0.1:8080';
$server = new \Twirp\Server();
$server->registerService(
    \Example\Twirp\Example\V1\HelloServiceClient::SERVICE_NAME, 
    new HelloServiceImpl()
);

echo "Starting Twirp server on $addr\n";
$server->serve($addr);