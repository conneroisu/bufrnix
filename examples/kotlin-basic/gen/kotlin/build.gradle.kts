import com.google.protobuf.gradle.*

plugins {
    kotlin("jvm") version "2.1.20"
    id("com.google.protobuf") version "0.9.5"
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("com.google.protobuf:protobuf-java:4.28.2")
    implementation("com.google.protobuf:protobuf-kotlin:4.28.2")
    
    
}

kotlin {
    jvmToolchain(17)
}

protobuf {
    protoc {
        artifact = "com.google.protobuf:protoc:4.28.2"
    }
    
    
    generateProtoTasks {
        all().forEach { task ->
            task.builtins {
                create("kotlin")
            }
            
            
        }
    }
}
