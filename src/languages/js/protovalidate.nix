{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib;
# Only activate if protovalidate is enabled
  (
    if cfg.enable or false
    then {
      # Runtime dependencies for protovalidate-es
      # Note: protovalidate-es doesn't have its own code generator,
      # it uses protoc-gen-es and adds runtime validation
      runtimeInputs = [];

      # No additional protoc plugins needed - validation rules are
      # embedded in the generated code by protoc-gen-es when it
      # detects buf.validate options in the proto files
      protocPlugins = [];

      # Initialize hook
      initHooks = ''
        echo "Enabling JavaScript/TypeScript validation with protovalidate-es..."

        # Ensure the ES module generator is configured with proper options
        ${optionalString ((cfg.target or "") == "ts" || (cfg.target or "") == "dts") ''
          echo "Generating TypeScript code with validation support..."
        ''}
      '';

      # Generate hook
      generateHooks = ''
        echo "Generated code includes validation annotations from buf.validate options."

        ${optionalString (cfg.generateValidationHelpers or true) ''
          echo ""
          echo "📦 Required runtime dependencies:"
          echo "   - @bufbuild/protobuf (for generated messages)"
          echo "   - @bufbuild/protovalidate (for runtime validation)"
          echo ""
          echo "Install with:"
          echo "  npm install @bufbuild/protobuf @bufbuild/protovalidate"
          echo "  # or"
          echo "  yarn add @bufbuild/protobuf @bufbuild/protovalidate"
          echo ""
          echo "Usage example:"
          echo '  import { createValidator } from "@bufbuild/protovalidate";'
          echo '  const validator = await createValidator();'
          echo '  const violations = await validator.validate(message);'
        ''}
      '';
    }
    else {}
  )
