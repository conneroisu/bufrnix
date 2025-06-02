# FindBufrnixProto.cmake
# Finds Bufrnix-generated Protocol Buffer files

if(NOT BUFRNIX_PROTO_FOUND)
  set(BUFRNIX_PROTO_ROOT "${CMAKE_CURRENT_LIST_DIR}/../../../")

  # Set include directory to generated proto path
  set(BUFRNIX_PROTO_INCLUDE_DIR "${BUFRNIX_PROTO_ROOT}/proto/gen/cpp")

  # Check if directory exists
  if(EXISTS "${BUFRNIX_PROTO_INCLUDE_DIR}")
    set(BUFRNIX_PROTO_FOUND TRUE)

    # Create imported target for protobuf
    if(NOT TARGET Bufrnix::Protobuf)
      add_library(Bufrnix::Protobuf INTERFACE IMPORTED)
      set_target_properties(Bufrnix::Protobuf PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${BUFRNIX_PROTO_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES
          "/nix/store/88ma4lbybcpdg0z8745nw9mvj5anb7mq-protobuf-30.2/lib/libprotobuf.so"
          "/nix/store/afacgi173j35xdc3rih1i2iadx8k68vr-abseil-cpp-20250127.1/lib/libabsl_log_internal_check_op.so"
          "/nix/store/afacgi173j35xdc3rih1i2iadx8k68vr-abseil-cpp-20250127.1/lib/libabsl_log_internal_message.so"
          "/nix/store/afacgi173j35xdc3rih1i2iadx8k68vr-abseil-cpp-20250127.1/lib/libabsl_status.so"
      )
    endif()

    # Create imported target for gRPC
if(EXISTS "${BUFRNIX_PROTO_INCLUDE_DIR}/grpc" AND NOT TARGET Bufrnix::GRPC)
  add_library(Bufrnix::GRPC INTERFACE IMPORTED)
  set_target_properties(Bufrnix::GRPC PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${BUFRNIX_PROTO_INCLUDE_DIR}/grpc"
    INTERFACE_LINK_LIBRARIES "/nix/store/7fd5mc4law3jlw8wz80i43p5zql008fz-grpc-1.71.0/lib/libgrpc++.so"
  )
endif()

  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(BufrnixProto
  REQUIRED_VARS BUFRNIX_PROTO_INCLUDE_DIR
)

