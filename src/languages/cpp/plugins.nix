# C++ Plugin definitions for Bufrnix
{
  pkgs,
  lib,
  protobufPkg ? pkgs.protobuf,
  grpcPkg ? pkgs.grpc,
  ...
}:
with lib; {
  # Core protobuf C++ plugin (built into protoc)
  protobuf = {
    name = "protobuf";
    remote = false;
    path = "cpp"; # Built-in protoc plugin
    package = protobufPkg;
    defaultOptions = [
      "paths=source_relative"
    ];
    description = "Core Protocol Buffers C++ generator";
    enabled = true; # Always enabled for C++
  };

  # gRPC C++ plugin
  grpc = {
    name = "grpc";
    remote = false;
    path = "${grpcPkg}/bin/grpc_cpp_plugin";
    package = grpcPkg;
    defaultOptions = [
      "paths=source_relative"
    ];
    description = "gRPC C++ service generator";
    enabled = false; # Opt-in
  };

  # gRPC C++ mock generator for testing
  grpc-mock = {
    name = "grpc-mock";
    remote = false;
    path = "${grpcPkg}/bin/grpc_cpp_plugin";
    package = grpcPkg;
    defaultOptions = [
      "generate_mock_code=true"
      "paths=source_relative"
    ];
    description = "gRPC C++ mock generator for testing";
    enabled = false; # Opt-in
  };

  # Nanopb for embedded C/C++
  nanopb = {
    name = "nanopb";
    remote = false;
    path = "${pkgs.nanopb}/bin/protoc-gen-nanopb";
    package = pkgs.nanopb;
    defaultOptions = [
      "max_size=1024"
      "max_count=16"
    ];
    description = "Nanopb generator for embedded C/C++";
    enabled = false; # Opt-in for embedded use
  };

  # Pure C implementation
  protobuf-c = {
    name = "protobuf-c";
    remote = false;
    path = "${pkgs.protobuf-c}/bin/protoc-gen-c";
    package = pkgs.protobuf-c;
    defaultOptions = [];
    description = "Pure C code generator";
    enabled = false; # Opt-in for C projects
  };

  # FlatBuffers alternative serialization
  flatbuffers = {
    name = "flatbuffers";
    remote = false;
    path = "${pkgs.flatbuffers}/bin/flatc";
    package = pkgs.flatbuffers;
    defaultOptions = [
      "--cpp"
      "--scoped-enums"
    ];
    description = "FlatBuffers C++ generator for zero-copy serialization";
    enabled = false; # Alternative to protobuf
  };

  # Helper function to resolve plugin configuration
  resolvePlugin = name:
    if
      hasAttr name {
        inherit protobuf grpc grpc-mock nanopb protobuf-c flatbuffers;
      }
    then
      getAttr name {
        inherit protobuf grpc grpc-mock nanopb protobuf-c flatbuffers;
      }
    else throw "Unknown C++ plugin: ${name}. Available plugins: protobuf, grpc, grpc-mock, nanopb, protobuf-c, flatbuffers";

  # Get all available plugin names
  availablePlugins = ["protobuf" "grpc" "grpc-mock" "nanopb" "protobuf-c" "flatbuffers"];

  # Get plugins for specific use cases
  embeddedPlugins = ["nanopb" "protobuf-c"];
  performancePlugins = ["flatbuffers"];
  testingPlugins = ["grpc-mock"];
}
