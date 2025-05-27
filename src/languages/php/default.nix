{
  pkgs,
  config,
  lib,
  cfg ? config.languages.php,
  ...
}:
with lib; let
  # Define output path and options
  outputPath = cfg.outputPath;
  phpOptions = cfg.options;

  # PHP with extensions
  phpWithExtensions = pkgs.php.withExtensions ({ enabled, all }: enabled ++ 
    (optional cfg.grpc.enable all.grpc) ++
    (optional (cfg.grpc.enable || cfg.roadrunner.enable) all.protobuf)
  );

  # Import PHP-specific sub-modules
  grpcModule = if cfg.grpc.enable then import ./grpc.nix {
    inherit pkgs lib;
    cfg = cfg.grpc // {
      inherit outputPath;
      namespace = cfg.namespace;
      serviceNamespace = cfg.grpc.serviceNamespace;
    };
  } else { runtimeInputs = []; protocPlugins = []; initHooks = ""; generateHooks = ""; };

  roadrunnerModule = if cfg.roadrunner.enable then import ./roadrunner.nix {
    inherit pkgs lib;
    cfg = cfg.roadrunner // {
      inherit outputPath;
      namespace = cfg.namespace;
      grpcEnabled = cfg.grpc.enable;
    };
  } else { runtimeInputs = []; protocPlugins = []; initHooks = ""; generateHooks = ""; };

  # Legacy twirp module (deprecated)
  twirpModule = if cfg.twirp.enable then import ./twirp.nix {
    inherit pkgs lib;
    cfg = cfg.twirp // {
      inherit outputPath;
    };
  } else { runtimeInputs = []; protocPlugins = []; initHooks = ""; generateHooks = ""; };

  # Framework modules
  laravelModule = if cfg.frameworks.laravel.enable then import ./frameworks/laravel.nix {
    inherit pkgs lib;
    cfg = cfg.frameworks.laravel // {
      inherit outputPath;
      namespace = cfg.namespace;
    };
  } else { runtimeInputs = []; protocPlugins = []; initHooks = ""; generateHooks = ""; };

  symfonyModule = if cfg.frameworks.symfony.enable then import ./frameworks/symfony.nix {
    inherit pkgs lib;
    cfg = cfg.frameworks.symfony // {
      inherit outputPath;
      namespace = cfg.namespace;
    };
  } else { runtimeInputs = []; protocPlugins = []; initHooks = ""; generateHooks = ""; };

  # Async module
  asyncModule = if (cfg.async.reactphp.enable || cfg.async.swoole.enable || cfg.async.fibers.enable) 
    then import ./async.nix {
      inherit pkgs lib;
      cfg = cfg.async // {
        inherit outputPath;
        namespace = cfg.namespace;
      };
    } else { runtimeInputs = []; protocPlugins = []; initHooks = ""; generateHooks = ""; };

  # Combine all sub-modules
  combineModuleAttrs = attr:
    concatLists (catAttrs attr [
      grpcModule
      roadrunnerModule
      twirpModule
      laravelModule
      symfonyModule
      asyncModule
    ]);

  # Build PHP namespace options
  namespaceOptions = concatStringsSep "," (filter (s: s != "") [
    (optionalString (cfg.namespace != "") "php_namespace=${cfg.namespace}")
    (optionalString (cfg.metadataNamespace != "") "php_metadata_namespace=${cfg.metadataNamespace}")
    (optionalString (cfg.classPrefix != "") "php_class_prefix=${cfg.classPrefix}")
  ]);

in {
  # Runtime dependencies for PHP code generation
  runtimeInputs = [
    # Base PHP dependencies
    (cfg.package or phpWithExtensions)
    pkgs.protobuf
  ] ++ (optional cfg.composer.enable pkgs.composer)
    ++ (combineModuleAttrs "runtimeInputs");

  # Protoc plugin configuration for PHP
  protocPlugins = [
    "--php_out=${outputPath}"
  ] ++ (optional (namespaceOptions != "") "--php_opt=${namespaceOptions}")
    ++ (combineModuleAttrs "protocPlugins");

  # Initialization hook for PHP
  initHooks = ''
    # Create php-specific directories
    mkdir -p "${outputPath}"
    
    ${optionalString (cfg.namespace != "") ''
      echo "PHP namespace: ${cfg.namespace}"
    ''}
    
    ${optionalString cfg.composer.enable ''
      # Initialize composer.json if it doesn't exist
      if [ ! -f composer.json ]; then
        echo "Creating composer.json..."
        cat > composer.json << 'EOF'
      {
        "name": "generated/protobuf",
        "description": "Generated Protocol Buffer code",
        "type": "library",
        "require": {
          "php": ">=7.4",
          "google/protobuf": "^3.21"
          ${optionalString cfg.grpc.enable '',"grpc/grpc": "^1.50"''}
          ${optionalString cfg.roadrunner.enable '',"spiral/roadrunner-grpc": "^3.0"''}
          ${optionalString cfg.roadrunner.enable '',"spiral/roadrunner-worker": "^3.0"''}
          ${optionalString cfg.async.reactphp.enable '',"react/event-loop": "${cfg.async.reactphp.version}"''}
          ${optionalString cfg.async.reactphp.enable '',"react/promise": "${cfg.async.reactphp.version}"''}
          ${optionalString cfg.async.swoole.enable '',"openswoole/core": "^22.0"''}
        },
        "autoload": {
          "psr-4": {
            "${cfg.namespace}\\": "${outputPath}/"
          }
        }
      }
      EOF
      fi
      
      ${optionalString cfg.composer.autoInstall ''
        if [ ! -d vendor ]; then
          echo "Installing Composer dependencies..."
          composer install --no-interaction --prefer-dist
        fi
      ''}
    ''}
  '' + concatStrings (catAttrs "initHooks" [
    grpcModule
    roadrunnerModule
    twirpModule
    laravelModule
    symfonyModule
    asyncModule
  ]);

  # Code generation hook for PHP
  generateHooks = ''
    # PHP-specific code generation steps
    echo "Generating PHP code with namespace ${cfg.namespace}..."
    
    # Ensure output directory exists
    mkdir -p ${outputPath}
    
    # Create autoload helper if needed
    ${optionalString cfg.composer.enable ''
      if [ -f composer.json ] && [ ! -f ${outputPath}/autoload.php ]; then
        cat > ${outputPath}/autoload.php << 'EOF'
      <?php
      /**
       * Generated Protocol Buffer autoloader
       * Include this file or use Composer autoloading
       */
      require_once __DIR__ . '/../vendor/autoload.php';
      EOF
      fi
    ''}
  '' + concatStrings (catAttrs "generateHooks" [
    grpcModule
    roadrunnerModule
    twirpModule
    laravelModule
    symfonyModule
    asyncModule
  ]);
}