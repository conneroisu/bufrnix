{
  lib,
  pkgs,
  self ? null,
  config ? {},
}:
with lib; let
  # Import our modules
  options = import ./bufrnix-options.nix {inherit lib;};
  debug = import ./utils/debug.nix {inherit lib;};

  # Merge defaults with user config
  cfg = recursiveUpdate options.options config;

  # Helper function to construct protoc command
  mkProtocCommand = cfg: let
    # Base protoc command
    protocCmd = [
      "${pkgs.protobuf}/bin/protoc"
      "--proto_path=${concatStringsSep " --proto_path=" cfg.protoc.includeDirectories}"
    ];

    # Go language options
    goOpts = optionals cfg.languages.go.enable [
      "--go_out=${cfg.languages.go.outputPath}"
      "--go_opt=${concatStringsSep " --go_opt=" cfg.languages.go.options}"
    ];

    # Go gRPC options
    goGrpcOpts = optionals (cfg.languages.go.enable && cfg.languages.go.grpc.enable) [
      "--go-grpc_out=${cfg.languages.go.outputPath}"
      "--go-grpc_opt=${concatStringsSep " --go-grpc_opt=" cfg.languages.go.grpc.options}"
    ];

    # Proto files selection
    protoFiles =
      if (cfg.protoc.files != [])
      then cfg.protoc.files
      else map (dir: "${dir}/**/*.proto") cfg.protoc.sourceDirectories;
  in
    concatStringsSep " " (protocCmd ++ goOpts ++ goGrpcOpts ++ protoFiles);

  # Create a wrapper script for the protoc command
  protocWrapper = pkgs.writeShellScriptBin "bufrnix_generate" ''
    #!/usr/bin/env bash
    set -e

    ${debug.log 1 "Starting code generation" cfg}
    ${debug.printCommand (mkProtocCommand cfg) cfg}

    # Create output directories
    ${optionalString cfg.languages.go.enable ''
      mkdir -p ${cfg.languages.go.outputPath}
      ${debug.log 2 "Created Go output directory: ${cfg.languages.go.outputPath}" cfg}
    ''}

    # Run protoc command
    ${debug.timeCommand (mkProtocCommand cfg) cfg}

    ${debug.log 1 "Code generation completed successfully" cfg}
  '';

  # Create a wrapper script for initialization
  initWrapper = pkgs.writeShellScriptBin "bufrnix_init" ''
        #!/usr/bin/env bash
        set -e

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
    name: ${
      if self != null
      then baseNameOf (toString self)
      else "bufrnix"
    }/example
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

    ${debug.log 1 "Starting linting" cfg}

    if ! command -v buf &> /dev/null; then
      echo "Error: 'buf' command not found. Please install buf CLI: https://buf.build/docs/installation"
      exit 1
    fi

    ${debug.printCommand "buf lint ${cfg.root}" cfg}
    ${debug.timeCommand "buf lint ${cfg.root}" cfg}

    ${debug.log 1 "Linting completed successfully" cfg}
  '';
in
  pkgs.symlinkJoin {
    name = "bufrnix";
    paths = [
      protocWrapper
      initWrapper
      lintWrapper
    ];
    buildInputs = with pkgs;
      [
        protobuf
      ]
      ++ optionals cfg.languages.go.enable [
        protoc-gen-go
      ]
      ++ optionals (cfg.languages.go.enable && cfg.languages.go.grpc.enable) [
        protoc-gen-go-grpc
      ];
  }
