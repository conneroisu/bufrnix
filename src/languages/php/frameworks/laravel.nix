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
  serviceProvider = cfg.serviceProvider or true;
  artisanCommands = cfg.artisanCommands or true;
  
in {
  # Runtime dependencies for Laravel integration
  runtimeInputs = [];

  # No additional protoc plugins needed for Laravel
  protocPlugins = [];

  # Initialization hooks for Laravel
  initHooks = optionalString enabled ''
    # Laravel framework integration
    echo "Setting up Laravel integration for Protocol Buffers..."
    
    # Create Laravel-specific directories
    mkdir -p app/Providers
    mkdir -p app/Console/Commands
    mkdir -p config
    
    # Create service provider if enabled
    ${optionalString serviceProvider ''
      if [ ! -f app/Providers/ProtobufServiceProvider.php ]; then
        echo "Creating Laravel ProtobufServiceProvider..."
        cat > app/Providers/ProtobufServiceProvider.php << 'EOF'
      <?php
      
      namespace App\Providers;
      
      use Illuminate\Support\ServiceProvider;
      use Grpc\ChannelCredentials;
      
      class ProtobufServiceProvider extends ServiceProvider
      {
          /**
           * Register services.
           */
          public function register(): void
          {
              // Register gRPC configuration
              $this->mergeConfigFrom(
                  __DIR__.'/../../config/grpc.php', 'grpc'
              );
              
              // Register gRPC clients as singletons
              $this->registerGrpcClients();
              
              // Register RoadRunner server if enabled
              if (config('grpc.roadrunner.enabled')) {
                  $this->registerRoadRunner();
              }
          }
          
          /**
           * Bootstrap services.
           */
          public function boot(): void
          {
              // Publish configuration
              $this->publishes([
                  __DIR__.'/../../config/grpc.php' => config_path('grpc.php'),
              ], 'grpc-config');
              
              // Register commands
              if ($this->app->runningInConsole()) {
                  $this->commands([
                      \App\Console\Commands\GrpcServe::class,
                      \App\Console\Commands\ProtobufGenerate::class,
                      \App\Console\Commands\GrpcHealthCheck::class,
                  ]);
              }
          }
          
          /**
           * Register gRPC client services
           */
          protected function registerGrpcClients(): void
          {
              // Example: Register your gRPC clients here
              // $this->app->singleton(\${namespace}\Services\ExampleServiceClient::class, function ($app) {
              //     $config = $app['config']['grpc.services.example'];
              //     
              //     return new \${namespace}\Services\ExampleServiceClient(
              //         $config['host'],
              //         [
              //             'credentials' => $config['tls'] 
              //                 ? ChannelCredentials::createSsl()
              //                 : ChannelCredentials::createInsecure(),
              //             'timeout' => $config['timeout'] * 1000000, // Convert to microseconds
              //         ]
              //     );
              // });
          }
          
          /**
           * Register RoadRunner gRPC server
           */
          protected function registerRoadRunner(): void
          {
              $this->app->singleton('grpc.server', function ($app) {
                  return new \Spiral\RoadRunner\GRPC\Server(null, [
                      'debug' => $app->isLocal(),
                  ]);
              });
              
              $this->app->singleton('grpc.registry', function ($app) {
                  return new \${namespace}\RoadRunner\ServiceRegistry(
                      $app['grpc.server']
                  );
              });
          }
      }
      EOF
      fi
    ''}
    
    # Create artisan commands if enabled
    ${optionalString artisanCommands ''
      if [ ! -f app/Console/Commands/ProtobufGenerate.php ]; then
        echo "Creating ProtobufGenerate artisan command..."
        cat > app/Console/Commands/ProtobufGenerate.php << 'EOF'
      <?php
      
      namespace App\Console\Commands;
      
      use Illuminate\Console\Command;
      use Symfony\Component\Process\Process;
      
      class ProtobufGenerate extends Command
      {
          /**
           * The name and signature of the console command.
           *
           * @var string
           */
          protected $signature = 'protobuf:generate 
                                 {--watch : Watch proto files for changes}
                                 {--lint : Run buf lint before generating}';
          
          /**
           * The console command description.
           *
           * @var string
           */
          protected $description = 'Generate PHP code from Protocol Buffer definitions';
          
          /**
           * Execute the console command.
           */
          public function handle(): int
          {
              $this->info('🚀 Generating Protocol Buffer code...');
              
              // Run buf lint if requested
              if ($this->option('lint')) {
                  $this->info('Running buf lint...');
                  $process = new Process(['buf', 'lint']);
                  $process->run();
                  
                  if (!$process->isSuccessful()) {
                      $this->error('❌ Linting failed:');
                      $this->error($process->getErrorOutput());
                      return 1;
                  }
                  $this->info('✅ Linting passed');
              }
              
              // Run buf generate
              $command = ['buf', 'generate'];
              if ($this->option('watch')) {
                  $command[] = '--watch';
                  $this->info('👀 Watching for changes...');
              }
              
              $process = new Process($command);
              $process->setTimeout(null);
              $process->run(function ($type, $buffer) {
                  $this->output->write($buffer);
              });
              
              if (!$process->isSuccessful()) {
                  $this->error('❌ Generation failed');
                  return 1;
              }
              
              if (!$this->option('watch')) {
                  $this->info('✅ Protocol Buffer generation complete!');
                  $this->info('Generated files are in: ' . config('grpc.output_path', 'gen/php'));
              }
              
              return 0;
          }
      }
      EOF
      fi
      
      if [ ! -f app/Console/Commands/GrpcServe.php ]; then
        echo "Creating GrpcServe artisan command..."
        cat > app/Console/Commands/GrpcServe.php << 'EOF'
      <?php
      
      namespace App\Console\Commands;
      
      use Illuminate\Console\Command;
      use Symfony\Component\Process\Process;
      
      class GrpcServe extends Command
      {
          /**
           * The name and signature of the console command.
           *
           * @var string
           */
          protected $signature = 'grpc:serve 
                                 {--debug : Run in debug mode}
                                 {--workers=4 : Number of worker processes}';
          
          /**
           * The console command description.
           *
           * @var string
           */
          protected $description = 'Start the gRPC server using RoadRunner';
          
          /**
           * Execute the console command.
           */
          public function handle(): int
          {
              if (!config('grpc.roadrunner.enabled')) {
                  $this->error('RoadRunner is not enabled. Please set ROADRUNNER_ENABLED=true in your .env file.');
                  return 1;
              }
              
              $this->info('🚀 Starting gRPC server...');
              
              // Update RoadRunner config with worker count
              $workers = $this->option('workers');
              if ($workers) {
                  $this->updateRoadRunnerConfig($workers);
              }
              
              // Build command
              $command = ['rr', 'serve', '-c', '.rr.yaml'];
              if ($this->option('debug')) {
                  $command[] = '-d';
                  $this->info('Running in debug mode...');
              }
              
              // Start RoadRunner
              $process = new Process($command);
              $process->setTimeout(null);
              
              $this->info('gRPC server listening on: ' . config('grpc.host', 'localhost:9001'));
              $this->info('Press Ctrl+C to stop the server');
              
              $process->run(function ($type, $buffer) {
                  $this->output->write($buffer);
              });
              
              return $process->getExitCode();
          }
          
          /**
           * Update RoadRunner configuration
           */
          protected function updateRoadRunnerConfig(int $workers): void
          {
              // This is a simplified example
              // In production, you'd want to properly parse and update the YAML
              $this->info("Setting worker count to: $workers");
          }
      }
      EOF
      fi
      
      if [ ! -f app/Console/Commands/GrpcHealthCheck.php ]; then
        echo "Creating GrpcHealthCheck artisan command..."
        cat > app/Console/Commands/GrpcHealthCheck.php << 'EOF'
      <?php
      
      namespace App\Console\Commands;
      
      use Illuminate\Console\Command;
      use Grpc\Health\V1\HealthCheckRequest;
      use Grpc\Health\V1\HealthClient;
      use Grpc\ChannelCredentials;
      
      class GrpcHealthCheck extends Command
      {
          /**
           * The name and signature of the console command.
           *
           * @var string
           */
          protected $signature = 'grpc:health 
                                 {--service= : Check specific service health}
                                 {--host=localhost:9001 : gRPC server host}';
          
          /**
           * The console command description.
           *
           * @var string
           */
          protected $description = 'Check gRPC server health status';
          
          /**
           * Execute the console command.
           */
          public function handle(): int
          {
              $host = $this->option('host');
              $service = $this->option('service') ?: '';
              
              $this->info("Checking health of gRPC server at $host...");
              
              try {
                  // Create health check client
                  $client = new HealthClient($host, [
                      'credentials' => ChannelCredentials::createInsecure(),
                      'timeout' => 5000000, // 5 seconds
                  ]);
                  
                  // Create request
                  $request = new HealthCheckRequest();
                  if ($service) {
                      $request->setService($service);
                      $this->info("Checking service: $service");
                  }
                  
                  // Make health check call
                  list($response, $status) = $client->Check($request)->wait();
                  
                  if ($status->code !== \Grpc\STATUS_OK) {
                      $this->error('❌ Health check failed: ' . $status->details);
                      return 1;
                  }
                  
                  // Display health status
                  $healthStatus = $response->getStatus();
                  switch ($healthStatus) {
                      case \Grpc\Health\V1\HealthCheckResponse\ServingStatus::SERVING:
                          $this->info('✅ Server is healthy and serving');
                          break;
                      case \Grpc\Health\V1\HealthCheckResponse\ServingStatus::NOT_SERVING:
                          $this->warn('⚠️  Server is not serving');
                          return 1;
                      case \Grpc\Health\V1\HealthCheckResponse\ServingStatus::SERVICE_UNKNOWN:
                          $this->error('❌ Service unknown');
                          return 1;
                      default:
                          $this->error('❌ Unknown status: ' . $healthStatus);
                          return 1;
                  }
                  
                  return 0;
                  
              } catch (\Exception $e) {
                  $this->error('❌ Failed to connect: ' . $e->getMessage());
                  return 1;
              }
          }
      }
      EOF
      fi
    ''}
    
    # Create gRPC configuration file
    if [ ! -f config/grpc.php ]; then
      echo "Creating gRPC configuration..."
      cat > config/grpc.php << 'EOF'
    <?php
    
    return [
        /*
        |--------------------------------------------------------------------------
        | gRPC Configuration
        |--------------------------------------------------------------------------
        |
        | Configure your gRPC clients and servers here.
        |
        */
        
        'host' => env('GRPC_HOST', 'localhost:9001'),
        'output_path' => env('GRPC_OUTPUT_PATH', 'gen/php'),
        
        /*
        |--------------------------------------------------------------------------
        | TLS Configuration
        |--------------------------------------------------------------------------
        */
        
        'tls' => [
            'enabled' => env('GRPC_TLS_ENABLED', false),
            'cert' => env('GRPC_TLS_CERT', 'server.crt'),
            'key' => env('GRPC_TLS_KEY', 'server.key'),
            'ca' => env('GRPC_TLS_CA', 'ca.crt'),
        ],
        
        /*
        |--------------------------------------------------------------------------
        | RoadRunner Configuration
        |--------------------------------------------------------------------------
        */
        
        'roadrunner' => [
            'enabled' => env('ROADRUNNER_ENABLED', false),
            'workers' => env('ROADRUNNER_WORKERS', 4),
            'max_jobs' => env('ROADRUNNER_MAX_JOBS', 64),
            'max_memory' => env('ROADRUNNER_MAX_MEMORY', 128),
        ],
        
        /*
        |--------------------------------------------------------------------------
        | Service Configuration
        |--------------------------------------------------------------------------
        |
        | Configure individual gRPC services here.
        |
        */
        
        'services' => [
            // 'example' => [
            //     'host' => env('EXAMPLE_SERVICE_HOST', 'localhost:9002'),
            //     'timeout' => env('EXAMPLE_SERVICE_TIMEOUT', 30),
            //     'tls' => env('EXAMPLE_SERVICE_TLS', false),
            // ],
        ],
        
        /*
        |--------------------------------------------------------------------------
        | Client Options
        |--------------------------------------------------------------------------
        |
        | Default options for all gRPC clients.
        |
        */
        
        'client_options' => [
            'timeout' => env('GRPC_CLIENT_TIMEOUT', 30),
            'wait_for_ready' => env('GRPC_WAIT_FOR_READY', false),
        ],
    ];
    EOF
    fi
  '';

  # Code generation hooks for Laravel
  generateHooks = optionalString enabled ''
    # Laravel-specific post-generation tasks
    echo "Configuring Laravel integration..."
    
    # Add service provider to config/app.php if not already there
    if [ -f config/app.php ] && ! grep -q "ProtobufServiceProvider" config/app.php; then
      echo ""
      echo "📝 Add the following to your config/app.php providers array:"
      echo "    App\Providers\ProtobufServiceProvider::class,"
      echo ""
    fi
    
    # Add environment variables if .env exists
    if [ -f .env ] && ! grep -q "GRPC_HOST" .env; then
      echo ""
      echo "📝 Add the following to your .env file:"
      echo "# gRPC Configuration"
      echo "GRPC_HOST=localhost:9001"
      echo "GRPC_TLS_ENABLED=false"
      echo "ROADRUNNER_ENABLED=true"
      echo "ROADRUNNER_WORKERS=4"
      echo ""
    fi
    
    echo "Laravel integration complete!"
    echo ""
    echo "Available artisan commands:"
    echo "  php artisan protobuf:generate    # Generate Protocol Buffer code"
    echo "  php artisan grpc:serve          # Start gRPC server"
    echo "  php artisan grpc:health         # Check server health"
    echo ""
  '';
}