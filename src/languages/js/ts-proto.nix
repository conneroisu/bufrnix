{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib;
# Only activate if ts-proto is enabled
  if cfg.enable or false
  then let
    outputPath = cfg.outputPath or "gen/js";
    tsProtoOptions = cfg.options or [];

    # Package ts-proto since it's not in nixpkgs yet
    protoc-gen-ts_proto = pkgs.buildNpmPackage rec {
      pname = "ts-proto";
      version = "1.181.1";

      src = pkgs.fetchFromGitHub {
        owner = "stephenh";
        repo = "ts-proto";
        rev = "v${version}";
        hash = "sha256-6Jvx6b1SMhGN9DNKFLvYvGrSdTXiPtz4fqnLZjjQCYI=";
      };

      npmDepsHash = "sha256-0FchqLDG6pHFB1nZ3dSvRRUzVyZqbShZPMBT8RZVz4o=";

      postInstall = ''
        # Create wrapper for protoc compatibility
        mkdir -p $out/bin
        makeWrapper $out/lib/node_modules/ts-proto/protoc-gen-ts_proto \
          $out/bin/protoc-gen-ts_proto \
          --prefix PATH : ${lib.makeBinPath [pkgs.nodejs]}
      '';

      meta = with lib; {
        description = "An idiomatic protobuf generator for TypeScript";
        homepage = "https://github.com/stephenh/ts-proto";
        license = licenses.asl20;
        maintainers = [];
      };
    };

    # Use provided package or fall back to our derivation
    tsProtoPackage = cfg.package or protoc-gen-ts_proto;

    # Default options for ts-proto
    defaultOptions = [
      "esModuleInterop=true"
      "outputServices=nice-grpc"
      "outputClientImpl=false"
      "useOptionals=messages"
      "useDate=date"
      "forceLong=string"
    ];

    # Merge default options with user options
    finalOptions =
      if tsProtoOptions == []
      then defaultOptions
      else tsProtoOptions;
  in {
    # Runtime dependencies for ts-proto code generation
    runtimeInputs = [
      tsProtoPackage
      pkgs.nodePackages.typescript
    ];

    # Protoc plugin configuration for ts-proto
    protocPlugins = [
      "--plugin=protoc-gen-ts_proto=${tsProtoPackage}/bin/protoc-gen-ts_proto"
      "--ts_proto_out=${outputPath}"
      (optionalString (finalOptions != []) "--ts_proto_opt=${concatStringsSep "," finalOptions}")
    ];

    # Initialization hook for ts-proto
    initHooks = ''
      # Create ts-proto specific directories
      mkdir -p "${outputPath}"
      echo "Initializing ts-proto code generation..."
    '';

    # Code generation hook for ts-proto
    generateHooks = ''
      # ts-proto specific generation steps
      echo "Generated ts-proto TypeScript interfaces to ${outputPath}"

      # Generate tsconfig.json if needed
      ${optionalString (cfg.generateTsConfig or false) ''
              cat > ${outputPath}/tsconfig.json <<EOF
        {
          "compilerOptions": {
            "target": "ES2020",
            "module": "ESNext",
            "moduleResolution": "node",
            "strict": true,
            "esModuleInterop": true,
            "skipLibCheck": true,
            "forceConsistentCasingInFileNames": true,
            "declaration": true,
            "declarationMap": true,
            "sourceMap": true,
            "outDir": "./dist"
          },
          "include": ["./**/*.ts"],
          "exclude": ["node_modules", "dist"]
        }
        EOF
      ''}

      # Generate package.json if needed
      ${optionalString (cfg.generatePackageJson or false) ''
              cat > ${outputPath}/package.json <<EOF
        {
          "name": "${cfg.packageName or "generated-ts-proto"}",
          "version": "1.0.0",
          "type": "module",
          "main": "./dist/index.js",
          "types": "./dist/index.d.ts",
          "scripts": {
            "build": "tsc",
            "clean": "rm -rf dist"
          },
          "dependencies": {
            "@grpc/grpc-js": "^1.10.0",
            "nice-grpc": "^2.1.7",
            "nice-grpc-common": "^2.0.2"
          },
          "devDependencies": {
            "typescript": "^5.3.0"
          }
        }
        EOF
      ''}
    '';
  }
  else {}
