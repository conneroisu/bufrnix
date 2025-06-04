{pkgs, lib, cfg, ...}:
with lib;
if cfg.enable then {
  # Runtime dependencies
  runtimeInputs = [ cfg.package ];
  
  # Note: protovalidate-java uses runtime validation, not code generation
  # We'll still generate standard Java protobuf code and include validation at runtime
  protocPlugins = [];
  
  # Additional initialization steps to add protovalidate dependency info
  initHooks = ''
    # Create a note about protovalidate-java runtime dependency
    mkdir -p "${cfg.outputPath}"
    cat > ${cfg.outputPath}/PROTOVALIDATE_README.txt << 'EOF'
This project uses protovalidate-java for runtime validation.

To use validation in your Java project, add this dependency:

Maven:
<dependency>
    <groupId>build.buf</groupId>
    <artifactId>protovalidate</artifactId>
    <version>0.1.8</version>
</dependency>

Gradle:
implementation 'build.buf:protovalidate:0.1.8'

Then use the Validator class to validate your protobuf messages at runtime.
EOF
  '';
} else {
  runtimeInputs = [];
  protocPlugins = [];
  initHooks = "";
}