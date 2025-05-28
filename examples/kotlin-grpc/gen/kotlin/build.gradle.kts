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
    implementation("io.grpc:grpc-kotlin-stub:1.4.2")
implementation("io.grpc:grpc-protobuf:1.62.2")
implementation("io.grpc:grpc-netty-shaded:1.62.2")
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.8.0")

    
}

kotlin {
    jvmToolchain(17)
}

protobuf {
    protoc {
        artifact = "com.google.protobuf:protoc:4.28.2"
    }
    plugins {
    create("grpc") {
        artifact = "io.grpc:protoc-gen-grpc-java:1.62.2"
    }
    create("grpckt") {
        artifact = "io.grpc:protoc-gen-grpc-kotlin:1.4.2:jdk8@jar"
    }
}

    
    generateProtoTasks {
        all().forEach { task ->
            task.builtins {
                create("kotlin")
            }
            task.plugins {
    create("grpc")
    create("grpckt")
}

            
        }
    }
}
