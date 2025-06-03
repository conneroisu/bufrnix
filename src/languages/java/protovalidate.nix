{ pkgs, lib, config, cfg, ... }:

with lib;

let
  protovalidateCfg = cfg.protovalidate;
  javaOutputPath = cfg.outputPath or "gen/java";
in
if protovalidateCfg.enable then {
  # Runtime dependencies
  runtimeInputs = [ protovalidateCfg.package cfg.jdk ];
  
  # Note: protovalidate-java uses runtime validation, not code generation
  # We'll still generate standard Java protobuf code and include validation at runtime
  protocPlugins = [];
  
  # Additional build steps to add protovalidate dependency info
  postBuild = ''
    # Create a note about protovalidate-java runtime dependency
    mkdir -p ${javaOutputPath}
    cat > ${javaOutputPath}/PROTOVALIDATE_README.txt << 'EOF'
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
} else {}