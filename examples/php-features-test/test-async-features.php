<?php
/**
 * Test script for async PHP features
 * This demonstrates ReactPHP, Swoole, and PHP Fibers integration
 */

// This would normally be autoloaded
// require_once 'vendor/autoload.php';

echo "PHP Async Features Test\n";
echo "======================\n\n";

// Test 1: ReactPHP example
echo "1. ReactPHP Example:\n";
echo "--------------------\n";
$reactExample = <<<'PHP'
use AsyncPHP\Proto\Async\ReactPHPClient;
use AsyncPHP\Proto\TestMessage;

$client = new ReactPHPClient('localhost:9001');

$message = new TestMessage();
$message->setName('ReactPHP Test');

$client->sendRequestAsync($message)->then(
    function ($response) {
        echo "Success: " . $response->getName() . "\n";
    },
    function ($error) {
        echo "Error: " . $error->getMessage() . "\n";
    }
);

$client->run();
PHP;
echo $reactExample . "\n\n";

// Test 2: Swoole example
echo "2. Swoole/OpenSwoole Example:\n";
echo "------------------------------\n";
$swooleExample = <<<'PHP'
use AsyncPHP\Proto\Async\SwooleGrpcServer;
use AsyncPHP\Proto\Async\SwooleGrpcClient;
use AsyncPHP\Proto\TestMessage;

// Server
$server = new SwooleGrpcServer('0.0.0.0', 9501, true); // coroutines enabled
$server->registerService(TestServiceInterface::class, new TestService());
$server->start();

// Client with coroutines
$client = new SwooleGrpcClient('localhost', 9501);
$messages = [];
for ($i = 0; $i < 3; $i++) {
    $msg = new TestMessage();
    $msg->setName("Message $i");
    $messages[] = $msg;
}

// Send concurrent requests
$responses = $client->sendConcurrent($messages);
foreach ($responses as $response) {
    echo "Response: " . $response->getName() . "\n";
}
PHP;
echo $swooleExample . "\n\n";

// Test 3: PHP Fibers example
echo "3. PHP 8.1+ Fibers Example:\n";
echo "---------------------------\n";
$fibersExample = <<<'PHP'
use AsyncPHP\Proto\Async\FiberProtobufHandler;
use AsyncPHP\Proto\TestMessage;

$handler = new FiberProtobufHandler();

// Create test messages
$messages = [];
for ($i = 1; $i <= 5; $i++) {
    $msg = new TestMessage();
    $msg->setName("Fiber Test $i");
    $msg->setValue($i * 10);
    $messages["msg$i"] = $msg->serializeToString();
}

// Process concurrently with Fibers
$results = $handler->processConcurrent($messages);

foreach ($results as $id => $result) {
    $response = new TestMessage();
    $response->mergeFromString($result);
    echo "$id: " . $response->getName() . " (value: " . $response->getValue() . ")\n";
}

// Batch processing with rate limiting
echo "\nBatch processing with rate limit:\n";
$generator = $handler->batchProcessWithRateLimit($messages, 3); // max 3 concurrent

foreach ($generator as $id => $result) {
    echo "Processed $id\n";
}
PHP;
echo $fibersExample . "\n\n";

// Test 4: Framework integration examples
echo "4. Framework Integration:\n";
echo "------------------------\n";

echo "Laravel Controller with async gRPC:\n";
$laravelExample = <<<'PHP'
namespace App\Http\Controllers;

use App\Proto\Async\ReactPHPClient;
use App\Proto\TestMessage;
use Illuminate\Http\JsonResponse;

class AsyncTestController extends Controller
{
    private ReactPHPClient $client;
    
    public function __construct()
    {
        $this->client = new ReactPHPClient(config('grpc.host'));
    }
    
    public function testAsync(Request $request): JsonResponse
    {
        $message = new TestMessage();
        $message->setName($request->input('name'));
        
        $promise = $this->client->sendRequestAsync($message);
        
        // In a real app, you might use Laravel's queue system
        $promise->then(
            function ($response) {
                // Handle success
                event(new MessageProcessed($response));
            }
        );
        
        return response()->json(['status' => 'processing']);
    }
}
PHP;
echo $laravelExample . "\n\n";

echo "Symfony Messenger with Fibers:\n";
$symfonyExample = <<<'PHP'
namespace App\MessageHandler;

use App\Message\BatchProtobufMessage;
use App\Proto\Async\FiberProtobufHandler;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

#[AsMessageHandler]
class FiberBatchHandler
{
    private FiberProtobufHandler $handler;
    
    public function __construct()
    {
        $this->handler = new FiberProtobufHandler();
    }
    
    public function __invoke(BatchProtobufMessage $message): void
    {
        $messages = $message->getSerializedMessages();
        
        // Process batch with Fibers for concurrency
        $results = $this->handler->processConcurrent($messages);
        
        // Handle results
        foreach ($results as $id => $result) {
            // Process each result
        }
    }
}
PHP;
echo $symfonyExample . "\n\n";

// Test 5: Performance comparison
echo "5. Performance Comparison Setup:\n";
echo "--------------------------------\n";
$perfExample = <<<'PHP'
// Traditional synchronous processing
$start = microtime(true);
foreach ($messages as $message) {
    $response = processMessage($message); // Blocking
}
$syncTime = microtime(true) - $start;

// ReactPHP async processing
$start = microtime(true);
$promises = array_map([$client, 'sendRequestAsync'], $messages);
\React\Promise\all($promises)->then(function ($responses) use ($start) {
    $asyncTime = microtime(true) - $start;
    echo "ReactPHP time: {$asyncTime}s\n";
});

// Swoole coroutine processing
$start = microtime(true);
Co::run(function () use ($messages, $client, $start) {
    $responses = $client->sendConcurrent($messages);
    $swooleTime = microtime(true) - $start;
    echo "Swoole time: {$swooleTime}s\n";
});

// PHP Fibers processing
$start = microtime(true);
$results = $handler->processConcurrent($messages);
$fiberTime = microtime(true) - $start;

echo "Performance results:\n";
echo "Sync: {$syncTime}s\n";
echo "Fibers: {$fiberTime}s\n";
PHP;
echo $perfExample . "\n\n";

echo "All async features demonstrated successfully!\n";