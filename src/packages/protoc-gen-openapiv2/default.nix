{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule rec {
  pname = "protoc-gen-openapiv2";
  version = "2.19.0";

  src = pkgs.fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = "grpc-gateway";
    rev = "v${version}";
    sha256 = "sha256-mppN8twrOTIVK3TDQcv5fYZtXKPA34EWGPo31JxME1g=";
  };

  vendorHash = "sha256-R/V3J9vCSQppm59RCaJrDIS0Juff5htPl/GjTwhHEfQ=";
  subPackages = ["protoc-gen-openapiv2"];

  meta = with lib; {
    description = "A protoc plugin that generates OpenAPI v2 (Swagger) documents for gRPC services";
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    license = licenses.bsd3;
    maintainers = with maintainers; [];
  };
}
