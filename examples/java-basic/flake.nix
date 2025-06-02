{
  description = "Java basic protobuf example with bufrnix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bufrnix.url = "path:../..";
  };

  outputs = { nixpkgs, bufrnix, ... }:
    let
      allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        inherit system;
        pkgs = nixpkgs.legacyPackages.${system};
      });
      
    in 
    {
      devShells = forAllSystems ({ system, pkgs }: {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.gradle
            pkgs.maven
            pkgs.jdk17
            pkgs.protobuf
          ];
          
          shellHook = ''
            echo "Java Basic Protobuf Example"
            echo "Available commands:"
            echo "  nix run .#generate - Generate Java protobuf code"
            echo "  gradle build - Build with Gradle"
            echo "  mvn compile - Build with Maven"
          '';
        };
      });
      
      apps = forAllSystems ({ system, pkgs }: {
        default = {
          type = "app";
          program = "${pkgs.writeShellScript "generate-java" ''
            mkdir -p gen/java/src/main/java
            ${pkgs.protobuf}/bin/protoc \
              --proto_path=proto \
              --java_out=gen/java/src/main/java \
              proto/example/v1/person.proto
            
            # Generate build files
            cat > gen/java/build.gradle << 'EOF'
plugins {
    id 'java'
    id 'application'
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'com.google.protobuf:protobuf-java:4.30.2'
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

application {
    mainClass = 'com.example.Main'
}
EOF

            cat > gen/java/pom.xml << 'EOF'
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
        <protobuf.version>4.30.2</protobuf.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>com.google.protobuf</groupId>
            <artifactId>protobuf-java</artifactId>
            <version>''${protobuf.version}</version>
        </dependency>
    </dependencies>
</project>
EOF
            
            # Copy the example source code
            mkdir -p gen/java/src/main/java
            cp -r src/main/java/* gen/java/src/main/java/ 2>/dev/null || true
            
            echo "Generated Java protobuf code in gen/java/"
            echo "Source files copied to gen/java/src/main/java/"
          ''}";
        };
        generate = {
          type = "app";
          program = "${pkgs.writeShellScript "generate-java" ''
            mkdir -p gen/java/src/main/java
            ${pkgs.protobuf}/bin/protoc \
              --proto_path=proto \
              --java_out=gen/java/src/main/java \
              proto/example/v1/person.proto
            
            # Generate build files
            cat > gen/java/build.gradle << 'EOF'
plugins {
    id 'java'
    id 'application'
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'com.google.protobuf:protobuf-java:4.30.2'
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

application {
    mainClass = 'com.example.Main'
}
EOF

            cat > gen/java/pom.xml << 'EOF'
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
        <protobuf.version>4.30.2</protobuf.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>com.google.protobuf</groupId>
            <artifactId>protobuf-java</artifactId>
            <version>''${protobuf.version}</version>
        </dependency>
    </dependencies>
</project>
EOF
            
            # Copy the example source code
            mkdir -p gen/java/src/main/java
            cp -r src/main/java/* gen/java/src/main/java/ 2>/dev/null || true
            
            echo "Generated Java protobuf code in gen/java/"
            echo "Source files copied to gen/java/src/main/java/"
          ''}";
        };
      });
    };
}