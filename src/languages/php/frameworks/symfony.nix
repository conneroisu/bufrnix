{
  pkgs,
  lib,
  cfg,
  ...
}:
with lib; let
  enabled = cfg.enable or false;
  outputPath = cfg.outputPath;
  namespace = cfg.namespace or "Generated";
  bundle = cfg.bundle or true;
  messengerIntegration = cfg.messengerIntegration or true;
  
in {
  # Runtime dependencies for Symfony integration
  runtimeInputs = [];

  # No additional protoc plugins needed for Symfony
  protocPlugins = [];

  # Initialization hooks for Symfony
  initHooks = optionalString enabled ''
    # Symfony framework integration
    echo "Setting up Symfony integration for Protocol Buffers..."
    
    # Create Symfony-specific directories
    mkdir -p src/Protobuf
    mkdir -p src/Command
    mkdir -p src/MessageHandler
    mkdir -p config/packages
    
    # Create bundle if enabled
    ${optionalString bundle ''
      if [ ! -f src/Protobuf/ProtobufBundle.php ]; then
        echo "Creating Symfony ProtobufBundle..."
        cat > src/Protobuf/ProtobufBundle.php << 'EOF'
      <?php
      
      namespace App\Protobuf;
      
      use Symfony\Component\HttpKernel\Bundle\Bundle;
      use Symfony\Component\DependencyInjection\ContainerBuilder;
      use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;
      use Symfony\Component\Config\Definition\Builder\TreeBuilder;
      use Symfony\Component\Config\Definition\ConfigurationInterface;
      
      class ProtobufBundle extends Bundle implements ConfigurationInterface
      {
          /**
           * {@inheritdoc}
           */
          public function loadExtension(
              array $config,
              ContainerConfigurator $container,
              ContainerBuilder $builder
          ): void {
              $services = $container->services();
              
              // Set default parameters
              $container->parameters()
                  ->set('protobuf.grpc.host', $config['grpc']['host'] ?? 'localhost:9001')
                  ->set('protobuf.grpc.tls', $config['grpc']['tls'] ?? false)
                  ->set('protobuf.namespace', '${namespace}');
              
              // Register gRPC clients
              $this->registerGrpcClients($services, $config);
              
              // Register RoadRunner if enabled
              if ($config['roadrunner']['enabled'] ?? false) {
                  $this->registerRoadRunner($services, $config);
              }
              
              // Register Messenger handlers if enabled
              if ($config['messenger']['enabled'] ?? false) {
                  $this->registerMessengerHandlers($services);
              }
              
              // Register commands
              $this->registerCommands($services);
          }
          
          /**
           * {@inheritdoc}
           */
          public function getConfigTreeBuilder(): TreeBuilder
          {
              $treeBuilder = new TreeBuilder('protobuf');
              
              $treeBuilder->getRootNode()
                  ->children()
                      ->arrayNode('grpc')
                          ->children()
                              ->scalarNode('host')->defaultValue('localhost:9001')->end()
                              ->booleanNode('tls')->defaultFalse()->end()
                              ->integerNode('timeout')->defaultValue(30)->end()
                          ->end()
                      ->end()
                      ->arrayNode('roadrunner')
                          ->children()
                              ->booleanNode('enabled')->defaultFalse()->end()
                              ->integerNode('workers')->defaultValue(4)->end()
                              ->integerNode('max_jobs')->defaultValue(64)->end()
                          ->end()
                      ->end()
                      ->arrayNode('messenger')
                          ->children()
                              ->booleanNode('enabled')->defaultFalse()->end()
                          ->end()
                      ->end()
                      ->arrayNode('services')
                          ->useAttributeAsKey('name')
                          ->arrayPrototype()
                              ->children()
                                  ->scalarNode('host')->isRequired()->end()
                                  ->integerNode('timeout')->defaultValue(30)->end()
                                  ->booleanNode('tls')->defaultFalse()->end()
                              ->end()
                          ->end()
                      ->end()
                  ->end();
              
              return $treeBuilder;
          }
          
          /**
           * Register gRPC client services
           */
          private function registerGrpcClients($services, array $config): void
          {
              // Base gRPC client factory
              $services->set('protobuf.grpc.client_factory', GrpcClientFactory::class)
                  ->args([
                      '%protobuf.grpc.host%',
                      '%protobuf.grpc.tls%',
                  ]);
              
              // Register configured services
              foreach ($config['services'] ?? [] as $name => $serviceConfig) {
                  $services->set('grpc.client.' . $name, '${namespace}\Services\\' . ucfirst($name) . 'ServiceClient')
                      ->factory([service('protobuf.grpc.client_factory'), 'createClient'])
                      ->args([
                          '${namespace}\Services\\' . ucfirst($name) . 'ServiceClient',
                          $serviceConfig['host'],
                          $serviceConfig,
                      ])
                      ->public();
              }
          }
          
          /**
           * Register RoadRunner services
           */
          private function registerRoadRunner($services, array $config): void
          {
              $services->set('grpc.server', \Spiral\RoadRunner\GRPC\Server::class)
                  ->args([null, ['debug' => '%kernel.debug%']]);
              
              $services->set('grpc.worker', GrpcWorkerCommand::class)
                  ->args([
                      service('grpc.server'),
                      tagged_iterator('grpc.service'),
                  ])
                  ->tag('console.command');
          }
          
          /**
           * Register Messenger handlers
           */
          private function registerMessengerHandlers($services): void
          {
              $services->set(ProtobufMessageHandler::class)
                  ->tag('messenger.message_handler');
          }
          
          /**
           * Register console commands
           */
          private function registerCommands($services): void
          {
              $services->set(ProtobufGenerateCommand::class)
                  ->tag('console.command');
              
              $services->set(GrpcHealthCheckCommand::class)
                  ->tag('console.command');
          }
      }
      EOF
      fi
      
      # Create gRPC client factory
      if [ ! -f src/Protobuf/GrpcClientFactory.php ]; then
        cat > src/Protobuf/GrpcClientFactory.php << 'EOF'
      <?php
      
      namespace App\Protobuf;
      
      use Grpc\ChannelCredentials;
      
      class GrpcClientFactory
      {
          private string $defaultHost;
          private bool $defaultTls;
          
          public function __construct(string $defaultHost, bool $defaultTls = false)
          {
              $this->defaultHost = $defaultHost;
              $this->defaultTls = $defaultTls;
          }
          
          /**
           * Create a gRPC client instance
           */
          public function createClient(
              string $clientClass,
              ?string $host = null,
              array $options = []
          ): object {
              $host = $host ?? $this->defaultHost;
              $tls = $options['tls'] ?? $this->defaultTls;
              
              $credentials = $tls
                  ? ChannelCredentials::createSsl()
                  : ChannelCredentials::createInsecure();
              
              $clientOptions = [
                  'credentials' => $credentials,
                  'timeout' => ($options['timeout'] ?? 30) * 1000000, // Convert to microseconds
              ];
              
              return new $clientClass($host, $clientOptions);
          }
      }
      EOF
      fi
    ''}
    
    # Create console commands
    if [ ! -f src/Command/ProtobufGenerateCommand.php ]; then
      echo "Creating ProtobufGenerateCommand..."
      cat > src/Command/ProtobufGenerateCommand.php << 'EOF'
    <?php
    
    namespace App\Command;
    
    use Symfony\Component\Console\Attribute\AsCommand;
    use Symfony\Component\Console\Command\Command;
    use Symfony\Component\Console\Input\InputInterface;
    use Symfony\Component\Console\Input\InputOption;
    use Symfony\Component\Console\Output\OutputInterface;
    use Symfony\Component\Console\Style\SymfonyStyle;
    use Symfony\Component\Process\Process;
    
    #[AsCommand(
        name: 'protobuf:generate',
        description: 'Generate PHP code from Protocol Buffer definitions',
    )]
    class ProtobufGenerateCommand extends Command
    {
        protected function configure(): void
        {
            $this
                ->addOption('watch', 'w', InputOption::VALUE_NONE, 'Watch proto files for changes')
                ->addOption('lint', 'l', InputOption::VALUE_NONE, 'Run buf lint before generating');
        }
        
        protected function execute(InputInterface $input, OutputInterface $output): int
        {
            $io = new SymfonyStyle($input, $output);
            
            $io->title('Protocol Buffer Code Generation');
            
            // Run buf lint if requested
            if ($input->getOption('lint')) {
                $io->section('Running buf lint...');
                $process = new Process(['buf', 'lint']);
                $process->run();
                
                if (!$process->isSuccessful()) {
                    $io->error('Linting failed:');
                    $io->error($process->getErrorOutput());
                    return Command::FAILURE;
                }
                $io->success('Linting passed');
            }
            
            // Run buf generate
            $io->section('Generating code...');
            $command = ['buf', 'generate'];
            if ($input->getOption('watch')) {
                $command[] = '--watch';
                $io->info('Watching for changes...');
            }
            
            $process = new Process($command);
            $process->setTimeout(null);
            $process->run(function ($type, $buffer) use ($output) {
                $output->write($buffer);
            });
            
            if (!$process->isSuccessful()) {
                $io->error('Generation failed');
                return Command::FAILURE;
            }
            
            if (!$input->getOption('watch')) {
                $io->success('Protocol Buffer generation complete!');
            }
            
            return Command::SUCCESS;
        }
    }
    EOF
    fi
    
    if [ ! -f src/Command/GrpcWorkerCommand.php ]; then
      echo "Creating GrpcWorkerCommand..."
      cat > src/Command/GrpcWorkerCommand.php << 'EOF'
    <?php
    
    namespace App\Command;
    
    use Spiral\RoadRunner\GRPC\Server;
    use Spiral\RoadRunner\Worker;
    use Symfony\Component\Console\Attribute\AsCommand;
    use Symfony\Component\Console\Command\Command;
    use Symfony\Component\Console\Input\InputInterface;
    use Symfony\Component\Console\Output\OutputInterface;
    
    #[AsCommand(
        name: 'grpc:worker',
        description: 'Run gRPC worker for RoadRunner',
    )]
    class GrpcWorkerCommand extends Command
    {
        private Server $server;
        private iterable $services;
        
        public function __construct(Server $server, iterable $services)
        {
            parent::__construct();
            $this->server = $server;
            $this->services = $services;
        }
        
        protected function execute(InputInterface $input, OutputInterface $output): int
        {
            $output->writeln('Starting gRPC worker...');
            
            // Register all tagged services
            foreach ($this->services as $service) {
                $interfaces = class_implements($service);
                foreach ($interfaces as $interface) {
                    if (str_contains($interface, 'ServiceInterface')) {
                        $this->server->registerService($interface, $service);
                        $output->writeln("Registered service: " . get_class($service));
                    }
                }
            }
            
            // Start the server
            $this->server->serve(Worker::create());
            
            return Command::SUCCESS;
        }
    }
    EOF
    fi
    
    if [ ! -f src/Command/GrpcHealthCheckCommand.php ]; then
      echo "Creating GrpcHealthCheckCommand..."
      cat > src/Command/GrpcHealthCheckCommand.php << 'EOF'
    <?php
    
    namespace App\Command;
    
    use Grpc\Health\V1\HealthCheckRequest;
    use Grpc\Health\V1\HealthClient;
    use Grpc\ChannelCredentials;
    use Symfony\Component\Console\Attribute\AsCommand;
    use Symfony\Component\Console\Command\Command;
    use Symfony\Component\Console\Input\InputInterface;
    use Symfony\Component\Console\Input\InputOption;
    use Symfony\Component\Console\Output\OutputInterface;
    use Symfony\Component\Console\Style\SymfonyStyle;
    
    #[AsCommand(
        name: 'grpc:health',
        description: 'Check gRPC server health status',
    )]
    class GrpcHealthCheckCommand extends Command
    {
        protected function configure(): void
        {
            $this
                ->addOption('host', null, InputOption::VALUE_REQUIRED, 'gRPC server host', 'localhost:9001')
                ->addOption('service', 's', InputOption::VALUE_REQUIRED, 'Check specific service health');
        }
        
        protected function execute(InputInterface $input, OutputInterface $output): int
        {
            $io = new SymfonyStyle($input, $output);
            $host = $input->getOption('host');
            $service = $input->getOption('service') ?: '';
            
            $io->title('gRPC Health Check');
            $io->text("Checking server at: $host");
            
            try {
                $client = new HealthClient($host, [
                    'credentials' => ChannelCredentials::createInsecure(),
                    'timeout' => 5000000, // 5 seconds
                ]);
                
                $request = new HealthCheckRequest();
                if ($service) {
                    $request->setService($service);
                    $io->text("Service: $service");
                }
                
                list($response, $status) = $client->Check($request)->wait();
                
                if ($status->code !== \Grpc\STATUS_OK) {
                    $io->error('Health check failed: ' . $status->details);
                    return Command::FAILURE;
                }
                
                $healthStatus = $response->getStatus();
                switch ($healthStatus) {
                    case \Grpc\Health\V1\HealthCheckResponse\ServingStatus::SERVING:
                        $io->success('Server is healthy and serving');
                        break;
                    case \Grpc\Health\V1\HealthCheckResponse\ServingStatus::NOT_SERVING:
                        $io->warning('Server is not serving');
                        return Command::FAILURE;
                    case \Grpc\Health\V1\HealthCheckResponse\ServingStatus::SERVICE_UNKNOWN:
                        $io->error('Service unknown');
                        return Command::FAILURE;
                    default:
                        $io->error('Unknown status: ' . $healthStatus);
                        return Command::FAILURE;
                }
                
                return Command::SUCCESS;
                
            } catch (\Exception $e) {
                $io->error('Failed to connect: ' . $e->getMessage());
                return Command::FAILURE;
            }
        }
    }
    EOF
    fi
    
    # Create Messenger handler if enabled
    ${optionalString messengerIntegration ''
      if [ ! -f src/MessageHandler/ProtobufMessageHandler.php ]; then
        echo "Creating ProtobufMessageHandler..."
        cat > src/MessageHandler/ProtobufMessageHandler.php << 'EOF'
      <?php
      
      namespace App\MessageHandler;
      
      use App\Message\ProtobufMessage;
      use Symfony\Component\Messenger\Attribute\AsMessageHandler;
      use Psr\Log\LoggerInterface;
      
      #[AsMessageHandler]
      class ProtobufMessageHandler
      {
          private LoggerInterface $logger;
          
          public function __construct(LoggerInterface $logger)
          {
              $this->logger = $logger;
          }
          
          public function __invoke(ProtobufMessage $message): void
          {
              $this->logger->info('Processing protobuf message', [
                  'type' => $message->getType(),
                  'size' => strlen($message->getPayload()),
              ]);
              
              try {
                  // Deserialize the protobuf message
                  $className = $message->getType();
                  if (!class_exists($className)) {
                      throw new \RuntimeException("Unknown protobuf class: $className");
                  }
                  
                  $protobufMessage = new $className();
                  $protobufMessage->mergeFromString($message->getPayload());
                  
                  // Process the message based on its type
                  $this->processProtobufMessage($protobufMessage);
                  
                  $this->logger->info('Successfully processed protobuf message');
                  
              } catch (\Exception $e) {
                  $this->logger->error('Failed to process protobuf message', [
                      'error' => $e->getMessage(),
                      'trace' => $e->getTraceAsString(),
                  ]);
                  throw $e;
              }
          }
          
          private function processProtobufMessage($message): void
          {
              // Implement your message processing logic here
              // This is where you'd handle different message types
          }
      }
      EOF
      fi
      
      if [ ! -f src/Message/ProtobufMessage.php ]; then
        echo "Creating ProtobufMessage..."
        cat > src/Message/ProtobufMessage.php << 'EOF'
      <?php
      
      namespace App\Message;
      
      /**
       * Wrapper for protobuf messages in Symfony Messenger
       */
      class ProtobufMessage
      {
          private string $type;
          private string $payload;
          private array $metadata;
          
          public function __construct(string $type, string $payload, array $metadata = [])
          {
              $this->type = $type;
              $this->payload = $payload;
              $this->metadata = $metadata;
          }
          
          public function getType(): string
          {
              return $this->type;
          }
          
          public function getPayload(): string
          {
              return $this->payload;
          }
          
          public function getMetadata(): array
          {
              return $this->metadata;
          }
          
          /**
           * Create from a protobuf message instance
           */
          public static function fromProtobuf($message, array $metadata = []): self
          {
              return new self(
                  get_class($message),
                  $message->serializeToString(),
                  $metadata
              );
          }
      }
      EOF
      fi
    ''}
    
    # Create configuration file
    if [ ! -f config/packages/protobuf.yaml ]; then
      echo "Creating protobuf configuration..."
      cat > config/packages/protobuf.yaml << 'EOF'
    protobuf:
        grpc:
            host: '%env(GRPC_HOST)%'
            tls: '%env(bool:GRPC_TLS_ENABLED)%'
            timeout: '%env(int:GRPC_TIMEOUT)%'
        
        roadrunner:
            enabled: '%env(bool:ROADRUNNER_ENABLED)%'
            workers: '%env(int:ROADRUNNER_WORKERS)%'
            max_jobs: '%env(int:ROADRUNNER_MAX_JOBS)%'
        
        messenger:
            enabled: '%env(bool:PROTOBUF_MESSENGER_ENABLED)%'
        
        services:
            # Configure your gRPC service clients here
            # example:
            #     host: '%env(EXAMPLE_SERVICE_HOST)%'
            #     timeout: 30
            #     tls: false
    EOF
    fi
  '';

  # Code generation hooks for Symfony
  generateHooks = optionalString enabled ''
    # Symfony-specific post-generation tasks
    echo "Configuring Symfony integration..."
    
    # Register bundle in config/bundles.php if it exists
    if [ -f config/bundles.php ] && ! grep -q "ProtobufBundle" config/bundles.php; then
      echo ""
      echo "📝 Add the following to your config/bundles.php:"
      echo "    App\Protobuf\ProtobufBundle::class => ['all' => true],"
      echo ""
    fi
    
    # Add environment variables if .env exists
    if [ -f .env ] && ! grep -q "GRPC_HOST" .env; then
      echo ""
      echo "📝 Add the following to your .env file:"
      cat >> .env.example << 'EOF'
    
    ###> protobuf/grpc ###
    GRPC_HOST=localhost:9001
    GRPC_TLS_ENABLED=false
    GRPC_TIMEOUT=30
    ROADRUNNER_ENABLED=false
    ROADRUNNER_WORKERS=4
    ROADRUNNER_MAX_JOBS=64
    PROTOBUF_MESSENGER_ENABLED=false
    ###< protobuf/grpc ###
    EOF
      echo "Environment variables added to .env.example"
    fi
    
    echo "Symfony integration complete!"
    echo ""
    echo "Available console commands:"
    echo "  bin/console protobuf:generate    # Generate Protocol Buffer code"
    echo "  bin/console grpc:worker         # Start gRPC worker (RoadRunner)"
    echo "  bin/console grpc:health         # Check server health"
    echo ""
    
    ${optionalString messengerIntegration ''
      echo "Messenger integration is enabled. Protobuf messages can be:"
      echo "  - Dispatched using the message bus"
      echo "  - Processed by the ProtobufMessageHandler"
      echo ""
    ''}
  '';
}