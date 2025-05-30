<?php
/**
 * RoadRunner gRPC Worker
 * Generated by Bufrnix
 */
declare(strict_types=1);

use Spiral\RoadRunner\GRPC\Server;
use Spiral\RoadRunner\Worker;

require __DIR__ . '/vendor/autoload.php';

// Create gRPC server
$server = new Server(null, [
    'debug' => false, // Set to true for development
]);

// Register your service implementations here
// Example:
// $server->registerService(
//     \\Services\YourServiceInterface::class,
//     new \App\Services\YourServiceImplementation()
// );

// Start the server
$server->serve(Worker::create());
