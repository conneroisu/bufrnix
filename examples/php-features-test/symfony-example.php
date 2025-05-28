<?php
/**
 * Symfony Integration Example
 * This shows how to use the generated code in a Symfony application
 */

// Example 1: Symfony Controller with gRPC
namespace App\Controller;

use App\Proto\Example\V1\TestMessage;
use App\Proto\Example\V1\GetTestRequest;
use App\Proto\Example\V1\ListTestsRequest;
use App\Proto\Example\V1\Services\TestServiceClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;

#[Route('/api/tests', name: 'api_tests_')]
class TestApiController extends AbstractController
{
    public function __construct(
        private TestServiceClient $grpcClient,
        private ValidatorInterface $validator
    ) {}
    
    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(string $id): JsonResponse
    {
        $request = new GetTestRequest();
        $request->setId($id);
        
        try {
            [$response, $status] = $this->grpcClient->GetTest($request)->wait();
            
            if ($status->code !== \Grpc\STATUS_OK) {
                return $this->json([
                    'error' => 'gRPC call failed',
                    'code' => $status->code,
                    'details' => $status->details,
                ], 500);
            }
            
            if (!$response->getFound()) {
                throw $this->createNotFoundException('Test not found');
            }
            
            return $this->json($this->serializeTestMessage($response->getTest()));
            
        } catch (\Exception $e) {
            return $this->json([
                'error' => $e->getMessage(),
            ], 500);
        }
    }
    
    #[Route('', name: 'list', methods: ['GET'])]
    public function list(Request $request): JsonResponse
    {
        $listRequest = new ListTestsRequest();
        $listRequest->setPageSize($request->query->getInt('limit', 20));
        $listRequest->setPageToken($request->query->get('cursor', ''));
        
        // Add tag filters if provided
        $tags = $request->query->all('tags');
        if (!empty($tags)) {
            $listRequest->setTags($tags);
        }
        
        // Server streaming RPC
        $call = $this->grpcClient->ListTests($listRequest);
        
        $results = [];
        foreach ($call->responses() as $testMessage) {
            $results[] = $this->serializeTestMessage($testMessage);
        }
        
        $status = $call->getStatus();
        if ($status->code !== \Grpc\STATUS_OK) {
            return $this->json([
                'error' => 'Failed to list tests',
                'details' => $status->details,
            ], 500);
        }
        
        return $this->json([
            'data' => $results,
            'meta' => [
                'count' => count($results),
                'has_more' => !empty($listRequest->getPageToken()),
            ],
        ]);
    }
    
    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        // Create and validate protobuf message
        $testMessage = new TestMessage();
        $testMessage->setId(uniqid('test_'));
        $testMessage->setName($data['name'] ?? '');
        $testMessage->setValue($data['value'] ?? 0);
        $testMessage->setActive($data['active'] ?? true);
        
        if (isset($data['tags'])) {
            $testMessage->setTags($data['tags']);
        }
        
        if (isset($data['metadata'])) {
            foreach ($data['metadata'] as $key => $value) {
                $testMessage->getMetadata()[$key] = $value;
            }
        }
        
        // Use Symfony validator if configured
        $errors = $this->validator->validate($testMessage);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], 400);
        }
        
        // Send via client streaming RPC
        $call = $this->grpcClient->CreateTests();
        
        $createRequest = new CreateTestRequest();
        $createRequest->setTest($testMessage);
        
        $call->write($createRequest);
        $call->writesDone();
        
        [$response, $status] = $call->wait();
        
        if ($status->code !== \Grpc\STATUS_OK) {
            return $this->json([
                'error' => 'Failed to create test',
                'details' => $status->details,
            ], 500);
        }
        
        return $this->json([
            'message' => 'Test created',
            'data' => array_map(
                [$this, 'serializeTestMessage'],
                iterator_to_array($response->getTests())
            ),
        ], 201);
    }
    
    private function serializeTestMessage(TestMessage $message): array
    {
        return [
            'id' => $message->getId(),
            'name' => $message->getName(),
            'value' => $message->getValue(),
            'active' => $message->getActive(),
            'tags' => iterator_to_array($message->getTags()),
            'metadata' => $this->mapToArray($message->getMetadata()),
            'status' => $message->getStatus(),
        ];
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

// Example 2: Symfony Message Handler with Protobuf
namespace App\MessageHandler;

use App\Message\ProcessProtobufMessage;
use App\Proto\Example\V1\TestMessage;
use App\Proto\Example\V1\ComplexMessage;
use Psr\Log\LoggerInterface;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

#[AsMessageHandler]
class ProtobufMessageHandler
{
    public function __construct(
        private LoggerInterface $logger
    ) {}
    
    public function __invoke(ProcessProtobufMessage $message): void
    {
        $this->logger->info('Processing protobuf message', [
            'type' => $message->getMessageType(),
            'size' => strlen($message->getSerializedData()),
        ]);
        
        try {
            // Deserialize based on type
            $protobufMessage = match($message->getMessageType()) {
                TestMessage::class => $this->deserializeTestMessage($message->getSerializedData()),
                ComplexMessage::class => $this->deserializeComplexMessage($message->getSerializedData()),
                default => throw new \InvalidArgumentException('Unknown message type'),
            };
            
            // Process the message
            $this->processMessage($protobufMessage);
            
        } catch (\Exception $e) {
            $this->logger->error('Failed to process protobuf message', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            throw $e;
        }
    }
    
    private function deserializeTestMessage(string $data): TestMessage
    {
        $message = new TestMessage();
        $message->mergeFromString($data);
        return $message;
    }
    
    private function deserializeComplexMessage(string $data): ComplexMessage
    {
        $message = new ComplexMessage();
        $message->mergeFromString($data);
        return $message;
    }
    
    private function processMessage($message): void
    {
        if ($message instanceof TestMessage) {
            $this->logger->info('Processing TestMessage', [
                'id' => $message->getId(),
                'name' => $message->getName(),
                'tags' => iterator_to_array($message->getTags()),
            ]);
            
            // Your business logic here
        } elseif ($message instanceof ComplexMessage) {
            $this->logger->info('Processing ComplexMessage', [
                'string_field' => $message->getStringField(),
                'bool_field' => $message->getBoolField(),
            ]);
            
            // Handle complex message
        }
    }
}

// Example 3: Symfony Command for gRPC Worker
namespace App\Command;

use App\Proto\Example\V1\Services\TestServiceInterface;
use App\Service\TestServiceImplementation;
use Spiral\RoadRunner\GRPC\Server;
use Spiral\RoadRunner\Worker;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

#[AsCommand(
    name: 'grpc:worker',
    description: 'Run gRPC worker for RoadRunner',
)]
class GrpcWorkerCommand extends Command
{
    public function __construct(
        private TestServiceImplementation $testService
    ) {
        parent::__construct();
    }
    
    protected function configure(): void
    {
        $this
            ->addOption('debug', 'd', InputOption::VALUE_NONE, 'Enable debug mode')
            ->addOption('workers', 'w', InputOption::VALUE_REQUIRED, 'Number of workers', 4);
    }
    
    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);
        $debug = $input->getOption('debug');
        
        $io->title('Starting gRPC Worker');
        
        try {
            $server = new Server(null, [
                'debug' => $debug,
            ]);
            
            // Register service
            $server->registerService(
                TestServiceInterface::class,
                $this->testService
            );
            
            $io->success('Service registered: ' . TestServiceInterface::class);
            
            if ($debug) {
                $io->note('Running in debug mode');
            }
            
            // Start serving
            $io->info('Worker is ready to handle requests...');
            $server->serve(Worker::create());
            
            return Command::SUCCESS;
            
        } catch (\Exception $e) {
            $io->error('Failed to start worker: ' . $e->getMessage());
            return Command::FAILURE;
        }
    }
}

// Example 4: Symfony Service Implementation
namespace App\Service;

use App\Proto\Example\V1\TestMessage;
use App\Proto\Example\V1\GetTestRequest;
use App\Proto\Example\V1\GetTestResponse;
use App\Proto\Example\V1\CreateTestRequest;
use App\Proto\Example\V1\CreateTestsResponse;
use App\Proto\Example\V1\Services\TestServiceInterface;
use Doctrine\ORM\EntityManagerInterface;
use Psr\Log\LoggerInterface;
use Spiral\RoadRunner\GRPC\ContextInterface;

class TestServiceImplementation implements TestServiceInterface
{
    public function __construct(
        private EntityManagerInterface $entityManager,
        private LoggerInterface $logger
    ) {}
    
    public function GetTest(ContextInterface $ctx, GetTestRequest $request): GetTestResponse
    {
        $this->logger->info('GetTest called', ['id' => $request->getId()]);
        
        // Fetch from database (example)
        $entity = $this->entityManager
            ->getRepository(TestEntity::class)
            ->find($request->getId());
        
        $response = new GetTestResponse();
        
        if ($entity) {
            $testMessage = new TestMessage();
            $testMessage->setId($entity->getId());
            $testMessage->setName($entity->getName());
            $testMessage->setValue($entity->getValue());
            $testMessage->setActive($entity->isActive());
            $testMessage->setTags($entity->getTags());
            
            $response->setTest($testMessage);
            $response->setFound(true);
        } else {
            $response->setFound(false);
        }
        
        return $response;
    }
    
    public function ListTests(ContextInterface $ctx, ListTestsRequest $request): \Generator
    {
        $this->logger->info('ListTests called', [
            'page_size' => $request->getPageSize(),
            'tags' => iterator_to_array($request->getTags()),
        ]);
        
        // Simulate streaming response
        $pageSize = $request->getPageSize() ?: 10;
        
        for ($i = 0; $i < $pageSize; $i++) {
            $testMessage = new TestMessage();
            $testMessage->setId("test_$i");
            $testMessage->setName("Test Item $i");
            $testMessage->setValue($i * 10);
            $testMessage->setActive(true);
            
            yield $testMessage;
            
            // Simulate work
            usleep(100000); // 100ms
        }
    }
    
    public function CreateTests(ContextInterface $ctx, \Iterator $requests): CreateTestsResponse
    {
        $this->logger->info('CreateTests called');
        
        $created = [];
        
        foreach ($requests as $request) {
            $testMessage = $request->getTest();
            
            // Create entity
            $entity = new TestEntity();
            $entity->setId($testMessage->getId());
            $entity->setName($testMessage->getName());
            $entity->setValue($testMessage->getValue());
            $entity->setActive($testMessage->getActive());
            $entity->setTags(iterator_to_array($testMessage->getTags()));
            
            $this->entityManager->persist($entity);
            $created[] = $testMessage;
        }
        
        $this->entityManager->flush();
        
        $response = new CreateTestsResponse();
        $response->setTests($created);
        $response->setCreatedCount(count($created));
        
        return $response;
    }
    
    public function StreamTests(ContextInterface $ctx, \Iterator $requests): \Generator
    {
        $this->logger->info('StreamTests called (bidirectional)');
        
        foreach ($requests as $request) {
            // Echo back with modifications
            $response = clone $request;
            $response->setName('[Echo] ' . $request->getName());
            $response->setValue($request->getValue() * 2);
            
            yield $response;
        }
    }
}

// Example 5: Symfony EventSubscriber for Protobuf
namespace App\EventSubscriber;

use App\Proto\Example\V1\TestMessage;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\KernelEvents;

class ProtobufSubscriber implements EventSubscriberInterface
{
    public static function getSubscribedEvents(): array
    {
        return [
            KernelEvents::REQUEST => 'onKernelRequest',
            KernelEvents::RESPONSE => 'onKernelResponse',
        ];
    }
    
    public function onKernelRequest(RequestEvent $event): void
    {
        $request = $event->getRequest();
        
        // Handle protobuf content type
        if ($request->headers->get('Content-Type') === 'application/x-protobuf') {
            $content = $request->getContent();
            
            // Deserialize protobuf
            $message = new TestMessage();
            $message->mergeFromString($content);
            
            // Convert to array for request attributes
            $request->attributes->set('protobuf_data', [
                'id' => $message->getId(),
                'name' => $message->getName(),
                'value' => $message->getValue(),
            ]);
        }
    }
    
    public function onKernelResponse(ResponseEvent $event): void
    {
        $request = $event->getRequest();
        $response = $event->getResponse();
        
        // Handle protobuf accept header
        if ($request->headers->get('Accept') === 'application/x-protobuf') {
            if ($response->headers->get('Content-Type') === 'application/json') {
                // Convert JSON response to protobuf
                $data = json_decode($response->getContent(), true);
                
                if (isset($data['id'], $data['name'], $data['value'])) {
                    $message = new TestMessage();
                    $message->setId($data['id']);
                    $message->setName($data['name']);
                    $message->setValue($data['value']);
                    
                    $response->setContent($message->serializeToString());
                    $response->headers->set('Content-Type', 'application/x-protobuf');
                }
            }
        }
    }
}

echo "Symfony integration examples created successfully!\n";