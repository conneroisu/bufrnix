{ pkgs, lib, config, cfg, ... }:

with lib;

let
  javaOutputPath = cfg.outputPath or "gen/java";
  
  # Import sub-modules
  grpcModule = import ./grpc.nix { inherit pkgs lib config cfg; };
  protovalidateModule = import ./protovalidate.nix { inherit pkgs lib config cfg; };
  
  # Java requires protoc's built-in Java generator
  javaPlugin = "--java_out=${javaOutputPath}";
  
  # Build the Java-specific protoc arguments
  javaArgs = concatStringsSep ":" cfg.options;
  
  fullJavaPlugin = if javaArgs != "" then "${javaPlugin}:${javaArgs}" else javaPlugin;
  
  # Merge all runtime inputs
  allRuntimeInputs = [ cfg.jdk cfg.package ] 
    ++ (grpcModule.runtimeInputs or [])
    ++ (protovalidateModule.runtimeInputs or []);
  
  # Merge all protoc plugins
  allProtocPlugins = [
    {
      name = "java";
      # Java uses protoc's built-in generator, not a separate plugin
      plugin = null;
      flags = [ fullJavaPlugin ];
    }
  ] ++ (grpcModule.protocPlugins or []) 
    ++ (protovalidateModule.protocPlugins or []);
  
  # Merge all post-build steps
  allPostBuild = ''
    # Ensure output directory exists
    mkdir -p ${javaOutputPath}
    
    # Generate build.gradle file for the Java project
    cat > ${javaOutputPath}/build.gradle << 'EOF'
plugins {
    id 'java'
    id 'application'
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'com.google.protobuf:protobuf-java:3.25.1'
    ${optionalString cfg.grpc.enable ''implementation 'io.grpc:grpc-stub:1.60.0'
    implementation 'io.grpc:grpc-protobuf:1.60.0'
    implementation 'io.grpc:grpc-netty-shaded:1.60.0'
    implementation 'javax.annotation:javax.annotation-api:1.3.2'''}
    ${optionalString cfg.protovalidate.enable ''implementation 'build.buf:protovalidate:0.1.8'''}
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
}
EOF
    
    # Generate Maven pom.xml as alternative
    cat > ${javaOutputPath}/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>generated-protos</artifactId>
    <version>1.0.0</version>
    
    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <protobuf.version>3.25.1</protobuf.version>
        ${optionalString cfg.grpc.enable ''<grpc.version>1.60.0</grpc.version>''}
        ${optionalString cfg.protovalidate.enable ''<protovalidate.version>0.1.8</protovalidate.version>''}
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>com.google.protobuf</groupId>
            <artifactId>protobuf-java</artifactId>
            <version>\${protobuf.version}</version>
        </dependency>
        ${optionalString cfg.grpc.enable ''
        <dependency>
            <groupId>io.grpc</groupId>
            <artifactId>grpc-stub</artifactId>
            <version>\${grpc.version}</version>
        </dependency>
        <dependency>
            <groupId>io.grpc</groupId>
            <artifactId>grpc-protobuf</artifactId>
            <version>\${grpc.version}</version>
        </dependency>
        <dependency>
            <groupId>io.grpc</groupId>
            <artifactId>grpc-netty-shaded</artifactId>
            <version>\${grpc.version}</version>
        </dependency>
        <dependency>
            <groupId>javax.annotation</groupId>
            <artifactId>javax.annotation-api</artifactId>
            <version>1.3.2</version>
        </dependency>''}
        ${optionalString cfg.protovalidate.enable ''
        <dependency>
            <groupId>build.buf</groupId>
            <artifactId>protovalidate</artifactId>
            <version>\${protovalidate.version}</version>
        </dependency>''}
    </dependencies>
</project>
EOF
  '' + (grpcModule.postBuild or "") + (protovalidateModule.postBuild or "");
in
{
  # Runtime dependencies
  runtimeInputs = allRuntimeInputs;
  
  # Protoc plugins configuration
  protocPlugins = allProtocPlugins;
  
  # Additional build steps
  postBuild = allPostBuild;
}