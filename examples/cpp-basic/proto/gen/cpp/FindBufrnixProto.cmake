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
          "/nix/store/8amcpfvr562pk1l3hpbhdl5j68gq919h-protobuf-30.2/lib/libprotobuf.dylib"
          "/nix/store/kb4dpn90blwbc1aac47cy06acd02dv3w-abseil-cpp-20250127.1/lib/libabsl_log_internal_check_op.dylib"
          "/nix/store/kb4dpn90blwbc1aac47cy06acd02dv3w-abseil-cpp-20250127.1/lib/libabsl_log_internal_message.dylib"
          "/nix/store/kb4dpn90blwbc1aac47cy06acd02dv3w-abseil-cpp-20250127.1/lib/libabsl_status.dylib"
      )
    endif()

    
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(BufrnixProto
  REQUIRED_VARS BUFRNIX_PROTO_INCLUDE_DIR
)

