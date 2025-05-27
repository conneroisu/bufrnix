<?php
/**
 * Laravel Integration Example
 * This shows how to use the generated code in a Laravel application
 */

// Example 1: Laravel Controller using gRPC client
namespace App\Http\Controllers;

use App\Proto\Example\V1\TestMessage;
use App\Proto\Example\V1\GetTestRequest;
use App\Proto\Example\V1\Services\TestServiceClient;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class TestController extends Controller
{
    private TestServiceClient $grpcClient;
    
    public function __construct(TestServiceClient $grpcClient)
    {
        // Client injected by Laravel's service container
        $this->grpcClient = $grpcClient;
    }
    
    /**
     * Get a test message via gRPC
     */
    public function show(string $id): JsonResponse
    {
        $request = new GetTestRequest();
        $request->setId($id);
        
        try {
            [$response, $status] = $this->grpcClient->GetTest($request)->wait();
            
            if ($status->code !== \Grpc\STATUS_OK) {
                return response()->json([
                    'error' => 'gRPC call failed',
                    'message' => $status->details
                ], 500);
            }
            
            $test = $response->getTest();
            
            return response()->json([
                'id' => $test->getId(),
                'name' => $test->getName(),
                'value' => $test->getValue(),
                'active' => $test->getActive(),
                'tags' => iterator_to_array($test->getTags()),
                'metadata' => $this->mapToArray($test->getMetadata()),
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Failed to fetch test',
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Create a new test message
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'value' => 'required|integer',
            'active' => 'boolean',
            'tags' => 'array',
            'tags.*' => 'string',
            'metadata' => 'array',
        ]);
        
        // Create protobuf message from request
        $testMessage = new TestMessage();
        $testMessage->setId(uniqid('test_'));
        $testMessage->setName($validated['name']);
        $testMessage->setValue($validated['value']);
        $testMessage->setActive($validated['active'] ?? true);
        
        if (!empty($validated['tags'])) {
            $testMessage->setTags($validated['tags']);
        }
        
        if (!empty($validated['metadata'])) {
            foreach ($validated['metadata'] as $key => $value) {
                $testMessage->getMetadata()[$key] = $value;
            }
        }
        
        // Send to gRPC service
        $createRequest = new CreateTestRequest();
        $createRequest->setTest($testMessage);
        
        // Use streaming RPC for batch creation
        $call = $this->grpcClient->CreateTests();
        $call->write($createRequest);
        $call->writesDone();
        
        [$response, $status] = $call->wait();
        
        if ($status->code !== \Grpc\STATUS_OK) {
            return response()->json([
                'error' => 'Failed to create test',
                'message' => $status->details
            ], 500);
        }
        
        return response()->json([
            'message' => 'Test created successfully',
            'created_count' => $response->getCreatedCount(),
            'tests' => array_map(function($test) {
                return [
                    'id' => $test->getId(),
                    'name' => $test->getName(),
                ];
            }, iterator_to_array($response->getTests())),
        ], 201);
    }
    
    /**
     * Stream test messages
     */
    public function stream(Request $request): JsonResponse
    {
        $listRequest = new ListTestsRequest();
        $listRequest->setPageSize($request->input('page_size', 10));
        
        if ($request->has('tags')) {
            $listRequest->setTags($request->input('tags'));
        }
        
        // Server streaming RPC
        $call = $this->grpcClient->ListTests($listRequest);
        
        $results = [];
        foreach ($call->responses() as $testMessage) {
            $results[] = [
                'id' => $testMessage->getId(),
                'name' => $testMessage->getName(),
                'value' => $testMessage->getValue(),
                'timestamp' => now()->toIso8601String(),
            ];
        }
        
        $status = $call->getStatus();
        if ($status->code !== \Grpc\STATUS_OK) {
            return response()->json([
                'error' => 'Stream failed',
                'message' => $status->details
            ], 500);
        }
        
        return response()->json([
            'data' => $results,
            'count' => count($results),
        ]);
    }
    
    private function mapToArray($map): array
    {
        $array = [];
        foreach ($map as $key => $value) {
            $array[$key] = $value;
        }
        return $array;
    }
}

// Example 2: Laravel Service Provider
namespace App\Providers;

use App\Proto\Example\V1\Services\TestServiceClient;
use Grpc\ChannelCredentials;
use Illuminate\Support\ServiceProvider;

class GrpcServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Register gRPC client as singleton
        $this->app->singleton(TestServiceClient::class, function ($app) {
            $config = $app['config']['grpc'];
            
            $credentials = $config['tls_enabled'] 
                ? ChannelCredentials::createSsl(
                    file_get_contents($config['tls_ca']),
                    file_get_contents($config['tls_key']),
                    file_get_contents($config['tls_cert'])
                )
                : ChannelCredentials::createInsecure();
            
            return new TestServiceClient($config['host'], [
                'credentials' => $credentials,
                'timeout' => $config['timeout'] * 1000000, // Convert to microseconds
                'wait_for_ready' => $config['wait_for_ready'],
            ]);
        });
        
        // Register RoadRunner gRPC server if enabled
        if ($this->app['config']['grpc.roadrunner.enabled']) {
            $this->app->singleton('grpc.server', function ($app) {
                return new \Spiral\RoadRunner\GRPC\Server(null, [
                    'debug' => $app->isLocal(),
                ]);
            });
        }
    }
    
    public function boot(): void
    {
        // Publish config
        $this->publishes([
            __DIR__.'/../../config/grpc.php' => config_path('grpc.php'),
        ], 'grpc-config');
        
        // Register commands if running in console
        if ($this->app->runningInConsole()) {
            $this->commands([
                \App\Console\Commands\GrpcServe::class,
                \App\Console\Commands\ProtobufGenerate::class,
            ]);
        }
    }
}

// Example 3: Laravel Queue Job with Protobuf
namespace App\Jobs;

use App\Proto\Example\V1\TestMessage;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class ProcessProtobufMessage implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;
    
    private string $serializedMessage;
    private string $messageType;
    
    public function __construct(TestMessage $message)
    {
        // Serialize protobuf for queue storage
        $this->serializedMessage = $message->serializeToString();
        $this->messageType = get_class($message);
    }
    
    public function handle(): void
    {
        // Deserialize the message
        $message = new $this->messageType();
        $message->mergeFromString($this->serializedMessage);
        
        // Process the message
        \Log::info('Processing protobuf message', [
            'id' => $message->getId(),
            'name' => $message->getName(),
            'tags' => iterator_to_array($message->getTags()),
        ]);
        
        // Perform business logic
        $this->processMessage($message);
    }
    
    private function processMessage(TestMessage $message): void
    {
        // Your business logic here
    }
}

// Example 4: Laravel API Resource with Protobuf
namespace App\Http\Resources;

use App\Proto\Example\V1\TestMessage;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TestMessageResource extends JsonResource
{
    /**
     * Transform the protobuf message into an array.
     */
    public function toArray(Request $request): array
    {
        /** @var TestMessage $this->resource */
        $message = $this->resource;
        
        return [
            'id' => $message->getId(),
            'name' => $message->getName(),
            'value' => $message->getValue(),
            'active' => $message->getActive(),
            'tags' => iterator_to_array($message->getTags()),
            'metadata' => $this->transformMetadata($message->getMetadata()),
            'nested' => $message->hasNested() ? [
                'nested_id' => $message->getNested()->getNestedId(),
                'nested_name' => $message->getNested()->getNestedName(),
            ] : null,
            'status' => $this->transformEnum($message->getStatus()),
            'created_at' => now()->toIso8601String(),
        ];
    }
    
    private function transformMetadata($metadata): array
    {
        $result = [];
        foreach ($metadata as $key => $value) {
            $result[$key] = $value;
        }
        return $result;
    }
    
    private function transformEnum(int $status): string
    {
        return match($status) {
            TestEnum::TEST_ENUM_ACTIVE => 'active',
            TestEnum::TEST_ENUM_INACTIVE => 'inactive',
            TestEnum::TEST_ENUM_PENDING => 'pending',
            default => 'unspecified',
        };
    }
}

echo "Laravel integration examples created successfully!\n";