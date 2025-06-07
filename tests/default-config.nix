{ pkgs }:
let
  lib = pkgs.lib;
  optionsDef = import ../src/lib/bufrnix-options.nix { inherit lib; };
  extractDefaults = options:
    if lib.isOption options then options.default or null
    else if lib.isAttrs options then lib.mapAttrs (_: extractDefaults) options
    else options;
  defaultConfig = extractDefaults optionsDef.options;
  packageDefaults = {
    languages.go = {
      package = pkgs.protoc-gen-go;
      grpc.package = pkgs.protoc-gen-go-grpc;
      gateway.package = pkgs.grpc-gateway;
      validate.package = pkgs.protoc-gen-validate;
      connect.package = pkgs.protoc-gen-connect-go;
      protovalidate.package = pkgs.protovalidate-go or null;
      openapiv2.package = pkgs.protoc-gen-openapiv2 or (pkgs.callPackage ../src/packages/protoc-gen-openapiv2 {});
      vtprotobuf.package = pkgs.protoc-gen-go-vtproto or (pkgs.callPackage ../src/packages/protoc-gen-go-vtproto {});
      json.package = pkgs.protoc-gen-go-json or (pkgs.callPackage ../src/packages/protoc-gen-go-json {});
      federation.package = pkgs.protoc-gen-grpc-federation or null;
      structTransformer.package = pkgs.protoc-gen-struct-transformer or (pkgs.callPackage ../src/languages/go/protoc-gen-struct-transformer.nix {});
    };
  };
  cfg = lib.recursiveUpdate (lib.recursiveUpdate defaultConfig packageDefaults) {};
in
  cfg
