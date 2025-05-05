{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.bufrnix;

  # Import our debug utilities
  debug = import ./lib/utils/debug.nix {inherit lib;};

  # Import language modules
  languageModules = [
    # Go language support
    ./languages/go/default.nix
    ./languages/go/grpc.nix
    ./languages/go/connect.nix
    ./languages/go/gateway.nix
    ./languages/go/validate.nix
    
    # Other language modules will be added here in future
  ];

  # Helper function to construct protoc command
  mkProtocCommand = cfg: let
    # Base protoc command
    protocCmd = [
      "${pkgs.protobuf}/bin/protoc"
      "--proto_path=${concatStringsSep " --proto_path=" cfg.protoc.includeDirectories}"
    ];

    # Proto files selection
    protoFiles =
      if (cfg.protoc.files != [])
      then cfg.protoc.files
      else map (dir: "${dir}/**/*.proto") cfg.protoc.sourceDirectories;
      
    # Start with empty flags array
    protoc_flags = []; 
    
    # For each enabled language module, collect their flags
    languageFlags = concatMap (module:
      optionals (module.enabledFlags or [])
    ) languageModules;
  in
    # Construct final command
    concatStringsSep " " (protocCmd ++ languageFlags ++ protoFiles);

  # Create a wrapper script for the protoc command
  protocWrapper = pkgs.writeShellScriptBin "bufrnix_generate" ''
    #!/usr/bin/env bash
    set -e
    
    # Setup debug handling if enabled
    ${debug.getDebugConfig cfg}

    ${debug.log 1 "Starting code generation" cfg}
    
    # Initialize the protoc flags array
    protoc_flags=()
    
    # Add base protoc command and include paths
    protoc_flags+=(
      "${pkgs.protobuf}/bin/protoc"
      ${concatMapStrings (dir: "--proto_path=${dir} ") cfg.protoc.includeDirectories}
    )
    
    # For each enabled language, add appropriate flags
    ${optionalString cfg.languages.go.enable ''
      # Add Go language flags
      mkdir -p ${cfg.languages.go.outputPath}
      ${debug.log 2 "Created Go output directory: ${cfg.languages.go.outputPath}" cfg}
      
      protoc_flags+=(
        "--go_out=${cfg.languages.go.outputPath}"
        ${concatMapStrings (opt: "--go_opt=${opt} ") cfg.languages.go.options}
      )
      
      ${optionalString cfg.languages.go.grpc.enable ''
        # Add Go gRPC flags
        protoc_flags+=(
          "--go-grpc_out=${cfg.languages.go.outputPath}"
          ${concatMapStrings (opt: "--go-grpc_opt=${opt} ") cfg.languages.go.grpc.options}
        )
      ''}
      
      ${optionalString (cfg.languages.go.gateway.enable or false) ''
        # Add Go gRPC Gateway flags if enabled
        protoc_flags+=(
          "--grpc-gateway_out=${cfg.languages.go.outputPath}"
          ${concatMapStrings (opt: "--grpc-gateway_opt=${opt} ") 
            (cfg.languages.go.gateway.options or ["paths=source_relative"])}
        )
      ''}
      
      ${optionalString (cfg.languages.go.validate.enable or false) ''
        # Add validation flags if enabled
        protoc_flags+=(
          "--validate_out=${cfg.languages.go.outputPath}"
          ${concatMapStrings (opt: "--validate_opt=${opt} ") 
            (cfg.languages.go.validate.options or ["lang=go"])}
        )
      ''}
    ''}
    
    # Add proto files
    ${if (cfg.protoc.files != [])
      then concatMapStrings (file: "protoc_flags+=(\"${file}\") ") cfg.protoc.files
      else concatMapStrings (dir: "protoc_flags+=(${dir}/**/*.proto) ") cfg.protoc.sourceDirectories
    }
    
    # Print the command in debug mode
    ${debug.printCommand "\${protoc_flags[*]}" cfg}
    
    # Run the command with timing in debug mode
    ${debug.timeCommand "\${protoc_flags[*]}" cfg}
    
    # Run any post-processing steps for languages
    ${optionalString cfg.languages.go.enable ''
      ${optionalString (cfg.languages.go.packagePrefix != "") ''
        # Update Go package prefixes if needed
        echo "Updating Go package prefixes with '${cfg.languages.go.packagePrefix}'"
        find ${cfg.languages.go.outputPath} -name "*.go" -type f -exec sed -i "s#package \\(.*\\)#package ${cfg.languages.go.packagePrefix}\\1#g" {} \;
        ${debug.log 2 "Updated Go package prefixes with '${cfg.languages.go.packagePrefix}'" cfg}
      ''}
    ''}

    ${debug.log 1 "Code generation completed successfully" cfg}
  '';

  # Create a wrapper script for initialization
  initWrapper = pkgs.writeShellScriptBin "bufrnix_init" ''
    #!/usr/bin/env bash
    set -e
    
    # Setup debug handling if enabled
    ${debug.getDebugConfig cfg}

    ${debug.log 1 "Initializing bufrnix project" cfg}

    # Create directory structure
    mkdir -p ${cfg.root}
    ${debug.log 2 "Created root directory: ${cfg.root}" cfg}

    # Create example proto file if none exist
    if [ -z "$(find ${cfg.root} -name '*.proto' 2>/dev/null)" ]; then
      mkdir -p ${cfg.root}/example/v1
      cat > ${cfg.root}/example/v1/example.proto << EOF
syntax = "proto3";

package example.v1;

${optionalString cfg.languages.go.enable ''
  option go_package = "${cfg.languages.go.packagePrefix}/example/v1;examplev1";
''}

// Example message
message Example {
  string id = 1;
  string name = 2;
  int32 value = 3;
}

// Example service
service ExampleService {
  rpc GetExample(GetExampleRequest) returns (GetExampleResponse);
}

message GetExampleRequest {
  string id = 1;
}

message GetExampleResponse {
  Example example = 1;
}
EOF
      ${debug.log 2 "Created example proto file: ${cfg.root}/example/v1/example.proto" cfg}
    fi

    # Create buf.yaml for linting
    cat > ${cfg.root}/buf.yaml << EOF
version: v1
name: bufrnix/example
build:
  roots:
    - ./
lint:
  use:
    - DEFAULT
EOF
    ${debug.log 2 "Created buf.yaml: ${cfg.root}/buf.yaml" cfg}

    ${debug.log 1 "Initialization completed successfully" cfg}
    echo "Bufrnix project initialized successfully!"
    echo "Run 'bufrnix_generate' to generate code from proto files."
  '';

  # Create a wrapper script for linting
  lintWrapper = pkgs.writeShellScriptBin "bufrnix_lint" ''
    #!/usr/bin/env bash
    set -e
    
    # Setup debug handling if enabled
    ${debug.getDebugConfig cfg}

    ${debug.log 1 "Starting linting" cfg}

    if ! command -v buf &> /dev/null; then
      echo "Error: 'buf' command not found. Please install buf CLI: https://buf.build/docs/installation"
      exit 1
    fi

    ${debug.printCommand "buf lint ${cfg.root}" cfg}
    ${debug.timeCommand "buf lint ${cfg.root}" cfg}

    ${debug.log 1 "Linting completed successfully" cfg}
  '';
  
  # Create a main entry script that handles subcommands
  mainScript = pkgs.writeShellScriptBin "bufrnix" ''
    #!/usr/bin/env bash
    set -e
    
    # Setup debug handling if enabled
    ${debug.getDebugConfig cfg}
    
    # Display version and general help if no arguments
    if [ $# -eq 0 ]; then
      echo "bufrnix v0.1.0 - Protocol Buffer Development with Nix"
      echo ""
      echo "Usage: bufrnix COMMAND [OPTIONS]"
      echo ""
      echo "Commands:"
      echo "  generate    Generate code from Protobuf definitions"
      echo "  init        Initialize a new Protobuf project"
      echo "  lint        Lint Protobuf files with buf"
      echo "  version     Show version information"
      echo "  help        Show this help message"
      echo ""
      echo "Options:"
      echo "  --debug     Enable debug output"
      echo "  --help      Show help for a command"
      echo ""
      echo "Environment Variables:"
      echo "  BUFRNIX_DEBUG         Set to enable debug output"
      echo "  BUFRNIX_DEBUG_LEVEL   Set debug verbosity (1-3)"
      echo "  BUFRNIX_DEBUG_LOG     Path to log file for debug output"
      echo ""
      exit 0
    fi
    
    # Handle command selection
    command="$1"
    shift
    
    case "$command" in
      generate|gen)
        ${debug.log 1 "Running generate command" cfg}
        exec bufrnix_generate "$@"
        ;;
      init)
        ${debug.log 1 "Running init command" cfg}
        exec bufrnix_init "$@"
        ;;
      lint)
        ${debug.log 1 "Running lint command" cfg}
        exec bufrnix_lint "$@"
        ;;
      version)
        echo "bufrnix v0.1.0"
        exit 0
        ;;
      help)
        echo "bufrnix v0.1.0 - Protocol Buffer Development with Nix"
        echo ""
        echo "Usage: bufrnix COMMAND [OPTIONS]"
        echo ""
        echo "Commands:"
        echo "  generate    Generate code from Protobuf definitions"
        echo "  init        Initialize a new Protobuf project"
        echo "  lint        Lint Protobuf files with buf"
        echo "  version     Show version information"
        echo "  help        Show this help message"
        echo ""
        echo "Options:"
        echo "  --debug     Enable debug output"
        echo "  --help      Show help for a command"
        echo ""
        echo "Environment Variables:"
        echo "  BUFRNIX_DEBUG         Set to enable debug output"
        echo "  BUFRNIX_DEBUG_LEVEL   Set debug verbosity (1-3)"
        echo "  BUFRNIX_DEBUG_LOG     Path to log file for debug output"
        echo ""
        exit 0
        ;;
      *)
        echo "Error: Unknown command '$command'"
        echo "Run 'bufrnix help' for usage information"
        exit 1
        ;;
    esac
  '';
in {
  # Import our options schema  
  options.bufrnix = import ./lib/bufrnix-options.nix {inherit lib;};
  
  # Make debug utils available to all modules
  _module.args.debug = debug;

  # Configuration for NixOS and other module users
  config = {
    # Create the bufrnix package based on configuration
    environment.systemPackages = [
      # Main scripts
      mainScript
      protocWrapper
      initWrapper
      lintWrapper
      
      # Go language support
      pkgs.protobuf
    ] 
    ++ optionals cfg.languages.go.enable [
      pkgs.protoc-gen-go
    ]
    ++ optionals (cfg.languages.go.enable && cfg.languages.go.grpc.enable) [
      pkgs.protoc-gen-go-grpc
    ]
    ++ optionals ((cfg.languages.go.enable && cfg.languages.go.gateway.enable or false) &&
                  (cfg.languages.go.gateway.package or null) != null) [
      cfg.languages.go.gateway.package
    ]
    ++ optionals ((cfg.languages.go.enable && cfg.languages.go.validate.enable or false) &&
                  (cfg.languages.go.validate.package or null) != null) [
      cfg.languages.go.validate.package
    ]
    ++ optionals ((cfg.languages.go.enable && cfg.languages.go.connect.enable or false) &&
                  (cfg.languages.go.connect.package or null) != null) [
      cfg.languages.go.connect.package
    ];
  };
}
