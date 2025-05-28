# Mapping of Buf registry plugin names to Nix packages and configurations
{
  pkgs,
  lib,
  ...
}:
with lib; {
  # Map Buf registry names to their corresponding Nix packages and configurations
  bufPluginMap = {
    # Official Buf/Protocol Buffers Plugins
    "buf.build/protocolbuffers/go" = {
      package = pkgs.protoc-gen-go;
      module = "base";
      options = ["paths=source_relative"];
    };

    "buf.build/grpc/go" = {
      package = pkgs.protoc-gen-go-grpc;
      module = "grpc";
      options = ["paths=source_relative"];
    };

    "buf.build/connectrpc/go" = {
      package = pkgs.protoc-gen-connect-go;
      module = "connect";
      options = ["paths=source_relative"];
    };

    "buf.build/bufbuild/validate-go" = {
      package = pkgs.protovalidate-go or null;
      module = "protovalidate";
      options = [];
    };

    # Community Performance & Feature Plugins
    "buf.build/community/planetscale-vtprotobuf" = {
      package = pkgs.protoc-gen-go-vtproto or null;
      module = "vtprotobuf";
      options = ["paths=source_relative" "features=marshal+unmarshal+size"];
    };

    "buf.build/community/mfridman-go-json" = {
      package = pkgs.protoc-gen-go-json or null;
      module = "json";
      options = ["paths=source_relative" "orig_name=true"];
    };

    "buf.build/community/mercari-grpc-federation" = {
      package = pkgs.protoc-gen-grpc-federation or null;
      module = "federation";
      options = ["paths=source_relative"];
    };

    # Additional plugins (not in Buf registry but commonly used)
    "grpc-gateway" = {
      package = pkgs.grpc-gateway;
      module = "gateway";
      options = ["paths=source_relative"];
    };

    "openapiv2" = {
      package = pkgs.protoc-gen-openapiv2 or null;
      module = "openapiv2";
      options = ["logtostderr=true"];
    };

    # Legacy plugins (for backwards compatibility)
    "validate" = {
      package = pkgs.protoc-gen-validate;
      module = "validate";
      options = ["lang=go"];
    };
  };

  # Helper function to resolve plugin configuration
  resolvePlugin = name:
    if hasAttr name bufPluginMap
    then bufPluginMap.${name}
    else throw "Unknown Go plugin: ${name}. Available plugins: ${concatStringsSep ", " (attrNames bufPluginMap)}";
}
