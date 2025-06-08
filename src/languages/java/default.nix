{
  pkgs,
  config,
  lib,
  cfg ? config.languages.java,
  ...
}:
with lib; let
  # Define output path and options
  outputPath = cfg.outputPath;
  javaOptions = cfg.options;

  # Import Java-specific sub-modules
  grpcModule = import ./grpc.nix {
    inherit pkgs lib;
    cfg =
      (cfg.grpc or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  protovalidateModule = import ./protovalidate.nix {
    inherit pkgs lib;
    cfg =
      (cfg.protovalidate or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  # Build Gradle dependencies section
  gradleDependencies =
    ''
      implementation 'com.google.protobuf:protobuf-java:4.31.1'
    ''
    + optionalString (cfg.grpc.enable or false) ''
      implementation 'io.grpc:grpc-stub:1.60.0'
      implementation 'io.grpc:grpc-protobuf:1.60.0'
      implementation 'io.grpc:grpc-netty-shaded:1.60.0'
      implementation 'javax.annotation:javax.annotation-api:1.3.2'
    ''
    + optionalString (cfg.protovalidate.enable or false) ''
      implementation 'build.buf:protovalidate:0.9.0'
    '';

  # Build Maven dependencies section
  mavenDependencies =
    ''
      <dependency>
          <groupId>com.google.protobuf</groupId>
          <artifactId>protobuf-java</artifactId>
          <version>''${protobuf.version}</version>
      </dependency>
    ''
    + optionalString (cfg.grpc.enable or false) ''
      <dependency>
          <groupId>io.grpc</groupId>
          <artifactId>grpc-stub</artifactId>
          <version>''${grpc.version}</version>
      </dependency>
      <dependency>
          <groupId>io.grpc</groupId>
          <artifactId>grpc-protobuf</artifactId>
          <version>''${grpc.version}</version>
      </dependency>
      <dependency>
          <groupId>io.grpc</groupId>
          <artifactId>grpc-netty-shaded</artifactId>
          <version>''${grpc.version}</version>
      </dependency>
      <dependency>
          <groupId>javax.annotation</groupId>
          <artifactId>javax.annotation-api</artifactId>
          <version>1.3.2</version>
      </dependency>
    ''
    + optionalString (cfg.protovalidate.enable or false) ''
      <dependency>
          <groupId>build.buf</groupId>
          <artifactId>protovalidate</artifactId>
          <version>''${protovalidate.version}</version>
      </dependency>
    '';

  # Maven properties
  mavenProperties =
    ''
      <maven.compiler.source>17</maven.compiler.source>
      <maven.compiler.target>17</maven.compiler.target>
      <protobuf.version>4.31.1</protobuf.version>
    ''
    + optionalString (cfg.grpc.enable or false) ''
      <grpc.version>1.60.0</grpc.version>
    ''
    + optionalString (cfg.protovalidate.enable or false) ''
      <protovalidate.version>0.9.0</protovalidate.version>
    '';

  # Combine all sub-modules
  combineModuleAttrs = attr:
    concatLists (catAttrs attr [
      grpcModule
      protovalidateModule
    ]);
in {
  # Runtime dependencies for Java code generation
  runtimeInputs =
    [
      cfg.package
      cfg.jdk
    ]
    ++ (combineModuleAttrs "runtimeInputs");

  # Protoc plugin configuration for Java
  protocPlugins =
    [
      "--java_out=${outputPath}"
    ]
    ++ (optionals (javaOptions != []) (map (opt: "--java_opt=${opt}") javaOptions))
    ++ (combineModuleAttrs "protocPlugins");

  # Initialization hook for Java
  initHooks =
    ''
            # Create Java-specific directories
            mkdir -p "${outputPath}"

            # Generate build.gradle file for the Java project
            cat > ${outputPath}/build.gradle <<'GRADLE_EOF'
      plugins {
          id 'java'
          id 'application'
      }

      repositories {
          mavenCentral()
      }

      dependencies {
      ${gradleDependencies}}

      java {
          sourceCompatibility = JavaVersion.VERSION_17
          targetCompatibility = JavaVersion.VERSION_17
      }
      GRADLE_EOF

            # Generate Maven pom.xml as alternative
            cat > ${outputPath}/pom.xml <<'POM_EOF'
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
      ${mavenProperties}    </properties>

          <dependencies>
      ${mavenDependencies}    </dependencies>
      </project>
      POM_EOF
    ''
    + concatStrings (catAttrs "initHooks" [
      grpcModule
      protovalidateModule
    ]);
}
