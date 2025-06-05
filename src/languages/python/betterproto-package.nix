{
  lib,
  stdenv,
  python3Packages,
  ...
}:
# Betterproto package for generating modern Python dataclasses from protobuf
# This provides the protoc-gen-python_betterproto plugin with all required dependencies
python3Packages.betterproto.overrideAttrs (oldAttrs: {
  propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
    python3Packages.black
    python3Packages.isort
  ];
})