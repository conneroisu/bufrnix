cmake_minimum_required(VERSION 3.16)
project(cpp-grpc-example CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Build options
option(BUILD_SERVER "Build the gRPC server" ON)
option(BUILD_CLIENT "Build the gRPC client" ON)

# Find required packages
find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)
find_package(PkgConfig REQUIRED)
find_package(OpenSSL REQUIRED)

# Find abseil (required by newer gRPC)
find_package(absl REQUIRED)

# Use pre-generated protobuf files from bufrnix
set(PROTO_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/proto/gen/cpp/example/v1/greeter.pb.cc
)

set(GRPC_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/proto/gen/cpp/example/v1/greeter.grpc.pb.cc
)

# Include generated headers
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/proto/gen/cpp)

# Create library for protobuf and gRPC files
add_library(grpc_proto_lib STATIC 
    ${PROTO_SRCS} 
    ${GRPC_SRCS} 
)

target_link_libraries(grpc_proto_lib
    PUBLIC
        protobuf::libprotobuf
        gRPC::grpc++
        gRPC::grpc++_reflection
        absl::base
        absl::memory
        absl::strings
        absl::log_internal_check_op
        absl::log_internal_message
        absl::status
)

# Server executable
if(BUILD_SERVER)
    add_executable(grpc-server src/server.cpp)
    target_link_libraries(grpc-server
        PRIVATE
            grpc_proto_lib
    )
    
    # Compiler specific options
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_compile_options(grpc-server PRIVATE
            -Wall
            -Wextra
            -O2
        )
    endif()
endif()

# Client executable
if(BUILD_CLIENT)
    add_executable(grpc-client src/client.cpp)
    target_link_libraries(grpc-client
        PRIVATE
            grpc_proto_lib
    )
    
    # Compiler specific options
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_compile_options(grpc-client PRIVATE
            -Wall
            -Wextra
            -O2
        )
    endif()
endif()

# Install targets
if(BUILD_SERVER)
    install(TARGETS grpc-server DESTINATION bin)
endif()

if(BUILD_CLIENT)
    install(TARGETS grpc-client DESTINATION bin)
endif()