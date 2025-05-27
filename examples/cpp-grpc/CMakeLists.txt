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

# Find abseil (required by newer gRPC)
find_package(absl REQUIRED)

# Add protobuf files
set(PROTO_FILES
    proto/example/v1/greeter.proto
)

# Generate protobuf and gRPC C++ files
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILES})

# Find the gRPC plugin
find_program(GRPC_CPP_PLUGIN grpc_cpp_plugin REQUIRED)

# Generate gRPC files
set(GRPC_SRCS)
set(GRPC_HDRS)
foreach(proto_file ${PROTO_FILES})
    get_filename_component(proto_name ${proto_file} NAME_WE)
    get_filename_component(proto_path ${proto_file} PATH)
    
    set(grpc_src "${CMAKE_CURRENT_BINARY_DIR}/${proto_path}/${proto_name}.grpc.pb.cc")
    set(grpc_hdr "${CMAKE_CURRENT_BINARY_DIR}/${proto_path}/${proto_name}.grpc.pb.h")
    
    list(APPEND GRPC_SRCS ${grpc_src})
    list(APPEND GRPC_HDRS ${grpc_hdr})
    
    add_custom_command(
        OUTPUT ${grpc_src} ${grpc_hdr}
        COMMAND protobuf::protoc
        ARGS --grpc_out=${CMAKE_CURRENT_BINARY_DIR}
             --cpp_out=${CMAKE_CURRENT_BINARY_DIR}
             --plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN}
             -I${CMAKE_CURRENT_SOURCE_DIR}
             ${CMAKE_CURRENT_SOURCE_DIR}/${proto_file}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${proto_file}
        COMMENT "Generating gRPC C++ files for ${proto_file}"
    )
endforeach()

# Include generated headers
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# Create library for protobuf and gRPC files
add_library(grpc_proto_lib STATIC 
    ${PROTO_SRCS} 
    ${PROTO_HDRS}
    ${GRPC_SRCS} 
    ${GRPC_HDRS}
)

target_link_libraries(grpc_proto_lib
    PUBLIC
        protobuf::libprotobuf
        gRPC::grpc++
        gRPC::grpc++_reflection
        absl::base
        absl::memory
        absl::strings
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