cmake_minimum_required(VERSION 3.16)
project(cpp-basic-example CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Find required packages
find_package(Protobuf REQUIRED)
find_package(absl REQUIRED)

# Include generated headers directory
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/proto/gen/cpp)

# Add generated protobuf sources
set(PROTO_SRCS
    proto/gen/cpp/example/v1/person.pb.cc
)

# Create library for protobuf files
add_library(proto_lib STATIC ${PROTO_SRCS})
target_link_libraries(proto_lib
    PUBLIC
        protobuf::libprotobuf
        absl::log_internal_check_op
        absl::log_internal_message
        absl::status
        absl::statusor
)

# Main executable
add_executable(cpp-basic-example
    src/main.cpp
)

target_link_libraries(cpp-basic-example
    PRIVATE
        proto_lib
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