{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation {
  name = "test-cpp-gen";

  buildInputs = [pkgs.protobuf];

  src = ./examples/cpp-basic/proto;

  buildPhase = ''
    mkdir -p $out/gen/cpp
    ${pkgs.protobuf}/bin/protoc \
      --cpp_out=$out/gen/cpp \
      --cpp_opt=paths=source_relative \
      -I. \
      example/v1/person.proto
  '';

  installPhase = ''
    echo "Generated files:"
    find $out -name "*.pb.*" -type f
  '';
}
