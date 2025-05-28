# BufrnixHelpers.cmake
# Helper functions for working with Bufrnix-generated files

function(bufrnix_collect_proto_sources out_var)
  cmake_parse_arguments(ARG "" "ROOT" "PATTERNS" ${ARGN})

  if(NOT ARG_ROOT)
    set(ARG_ROOT "${BUFRNIX_PROTO_INCLUDE_DIR}")
  endif()

  if(NOT ARG_PATTERNS)
    set(ARG_PATTERNS "*.pb.cc" "*.grpc.pb.cc")
  endif()

  set(collected_sources)
  foreach(pattern IN LISTS ARG_PATTERNS)
    file(GLOB_RECURSE pattern_sources
      "${ARG_ROOT}/${pattern}"
    )
    list(APPEND collected_sources ${pattern_sources})
  endforeach()

  set(${out_var} ${collected_sources} PARENT_SCOPE)
endfunction()

function(bufrnix_add_proto_executable target)
  cmake_parse_arguments(ARG "" "" "SOURCES;PROTO_SOURCES" ${ARGN})

  # Collect proto sources if not provided
  if(NOT ARG_PROTO_SOURCES)
    bufrnix_collect_proto_sources(ARG_PROTO_SOURCES)
  endif()

  add_executable(${target} ${ARG_SOURCES} ${ARG_PROTO_SOURCES})
  target_link_libraries(${target}
    PRIVATE
      Bufrnix::Protobuf
      Bufrnix::GRPC
  )
endfunction()

function(bufrnix_enable_cpp_features target)
  set_target_properties(${target} PROPERTIES
    CXX_STANDARD c++20
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
  )

  # Add optimization flags based on configuration
  target_compile_options(${target} PRIVATE -O3 -DNDEBUG)

  
  target_compile_definitions(${target} PRIVATE PROTOBUF_USE_ARENA=1)

endfunction()

