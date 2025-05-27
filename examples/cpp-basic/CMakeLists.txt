cmake_minimum_required(VERSION 3.16)
project(cpp-basic-example CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Find required packages
find_package(Protobuf REQUIRED)
find_package(PkgConfig REQUIRED)

# Add protobuf files
set(PROTO_FILES
    proto/example/v1/person.proto
)

# Generate protobuf C++ files
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILES})

# Include generated headers
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# Create library for protobuf files
add_library(proto_lib STATIC ${PROTO_SRCS} ${PROTO_HDRS})
target_link_libraries(proto_lib
    PUBLIC
        protobuf::libprotobuf
)

# Main executable
add_executable(cpp-basic-example
    src/main.cpp
)

target_link_libraries(cpp-basic-example
    PRIVATE
        proto_lib
        protobuf::libprotobuf
)

# Compiler specific options
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    target_compile_options(cpp-basic-example PRIVATE
        -Wall
        -Wextra
        -O2
    )
endif()

# Install
install(TARGETS cpp-basic-example DESTINATION bin)