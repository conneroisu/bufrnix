{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib; let
  enabled = cfg.cmakeIntegration or true;
  outputPath = cfg.outputPath or "gen/cpp";
  protobufPkg = cfg.protobufPkg or pkgs.protobuf;
  grpcPkg = cfg.grpcPkg;

  # Generate FindBufrnixProto.cmake
  findModuleContent = ''
    # FindBufrnixProto.cmake
    # Finds Bufrnix-generated Protocol Buffer files

    if(NOT BUFRNIX_PROTO_FOUND)
      set(BUFRNIX_PROTO_ROOT "''${CMAKE_CURRENT_LIST_DIR}/../../../")

      # Set include directory to generated proto path
      set(BUFRNIX_PROTO_INCLUDE_DIR "''${BUFRNIX_PROTO_ROOT}/${outputPath}")

      # Check if directory exists
      if(EXISTS "''${BUFRNIX_PROTO_INCLUDE_DIR}")
        set(BUFRNIX_PROTO_FOUND TRUE)

        # Create imported target for protobuf
        if(NOT TARGET Bufrnix::Protobuf)
          add_library(Bufrnix::Protobuf INTERFACE IMPORTED)
          set_target_properties(Bufrnix::Protobuf PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "''${BUFRNIX_PROTO_INCLUDE_DIR}"
            INTERFACE_LINK_LIBRARIES
              "${protobufPkg}/lib/libprotobuf${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}"
              "${pkgs.abseil-cpp}/lib/libabsl_log_internal_check_op${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}"
              "${pkgs.abseil-cpp}/lib/libabsl_log_internal_message${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}"
              "${pkgs.abseil-cpp}/lib/libabsl_status${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}"
          )
        endif()

        ${optionalString (grpcPkg != null) ''
      # Create imported target for gRPC
      if(EXISTS "''${BUFRNIX_PROTO_INCLUDE_DIR}/grpc" AND NOT TARGET Bufrnix::GRPC)
        add_library(Bufrnix::GRPC INTERFACE IMPORTED)
        set_target_properties(Bufrnix::GRPC PROPERTIES
          INTERFACE_INCLUDE_DIRECTORIES "''${BUFRNIX_PROTO_INCLUDE_DIR}/grpc"
          INTERFACE_LINK_LIBRARIES "${grpcPkg}/lib/libgrpc++${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}"
        )
      endif()
    ''}
      endif()
    endif()

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(BufrnixProto
      REQUIRED_VARS BUFRNIX_PROTO_INCLUDE_DIR
    )
  '';

  # Generate BufrnixHelpers.cmake with utility functions
  helpersContent = ''
    # BufrnixHelpers.cmake
    # Helper functions for working with Bufrnix-generated files

    function(bufrnix_collect_proto_sources out_var)
      cmake_parse_arguments(ARG "" "ROOT" "PATTERNS" ''${ARGN})

      if(NOT ARG_ROOT)
        set(ARG_ROOT "''${BUFRNIX_PROTO_INCLUDE_DIR}")
      endif()

      if(NOT ARG_PATTERNS)
        set(ARG_PATTERNS "*.pb.cc" "*.grpc.pb.cc")
      endif()

      set(collected_sources)
      foreach(pattern IN LISTS ARG_PATTERNS)
        file(GLOB_RECURSE pattern_sources
          "''${ARG_ROOT}/''${pattern}"
        )
        list(APPEND collected_sources ''${pattern_sources})
      endforeach()

      set(''${out_var} ''${collected_sources} PARENT_SCOPE)
    endfunction()

    function(bufrnix_add_proto_executable target)
      cmake_parse_arguments(ARG "" "" "SOURCES;PROTO_SOURCES" ''${ARGN})

      # Collect proto sources if not provided
      if(NOT ARG_PROTO_SOURCES)
        bufrnix_collect_proto_sources(ARG_PROTO_SOURCES)
      endif()

      add_executable(''${target} ''${ARG_SOURCES} ''${ARG_PROTO_SOURCES})
      target_link_libraries(''${target}
        PRIVATE
          Bufrnix::Protobuf
          ${optionalString (grpcPkg != null) "Bufrnix::GRPC"}
      )
    endfunction()

    function(bufrnix_enable_cpp_features target)
      set_target_properties(''${target} PROPERTIES
        CXX_STANDARD ${cfg.standard or "17"}
        CXX_STANDARD_REQUIRED ON
        CXX_EXTENSIONS OFF
      )

      # Add optimization flags based on configuration
      ${optionalString (cfg.optimizeFor == "SPEED") ''
      target_compile_options(''${target} PRIVATE -O3 -DNDEBUG)
    ''}
      ${optionalString (cfg.optimizeFor == "CODE_SIZE") ''
      target_compile_options(''${target} PRIVATE -Os)
    ''}
      ${optionalString (cfg.arenaAllocation or false) ''
      target_compile_definitions(''${target} PRIVATE PROTOBUF_USE_ARENA=1)
    ''}
    endfunction()
  '';
in {
  # Runtime dependencies for CMake integration
  runtimeInputs = optionals enabled [
    pkgs.cmake
  ];

  # No additional protoc plugins needed
  protocPlugins = [];

  # Initialization hooks for CMake
  initHooks = optionalString enabled ''
    echo "Setting up CMake integration for C++..."
  '';

  # Generation hooks for CMake - create the CMake files
  generateHooks = optionalString enabled ''
        echo "Generating CMake integration files..."

        # Create FindBufrnixProto.cmake
        cat > ${outputPath}/FindBufrnixProto.cmake << 'CMAKE_EOF'
    ${findModuleContent}
    CMAKE_EOF

        # Create BufrnixHelpers.cmake
        cat > ${outputPath}/BufrnixHelpers.cmake << 'CMAKE_EOF'
    ${helpersContent}
    CMAKE_EOF

        echo "CMake modules created in ${outputPath}/"
  '';
}
