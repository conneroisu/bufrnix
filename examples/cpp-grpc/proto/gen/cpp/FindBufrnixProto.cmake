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
          "/nix/store/2abn91wajq4jxl37dymvsh8hg6xg9kw0-protobuf-24.4/lib/libprotobuf.so"
          "/nix/store/3j9kmkqjzmv8nzwal713z20qm8pg0ylp-abseil-cpp-20240116.2/lib/libabsl_log_internal_check_op.so"
          "/nix/store/3j9kmkqjzmv8nzwal713z20qm8pg0ylp-abseil-cpp-20240116.2/lib/libabsl_log_internal_message.so"
          "/nix/store/3j9kmkqjzmv8nzwal713z20qm8pg0ylp-abseil-cpp-20240116.2/lib/libabsl_status.so"
      )
    endif()

    # Create imported target for gRPC
if(EXISTS "${BUFRNIX_PROTO_INCLUDE_DIR}/grpc" AND NOT TARGET Bufrnix::GRPC)
  add_library(Bufrnix::GRPC INTERFACE IMPORTED)
  set_target_properties(Bufrnix::GRPC PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${BUFRNIX_PROTO_INCLUDE_DIR}/grpc"
    INTERFACE_LINK_LIBRARIES "/nix/store/z6b1yvld4q2my3rd07d9awv1cnbc2zhb-grpc-1.62.3/lib/libgrpc++.so"
  )
endif()

  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(BufrnixProto
  REQUIRED_VARS BUFRNIX_PROTO_INCLUDE_DIR
)

