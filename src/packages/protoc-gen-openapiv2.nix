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
    sha256 = "sha256-zLAIZce0A2G5q6orevUGkgKEQhgXutpyJJaWLqVaOqA=";
  };

  vendorHash = "sha256-S4hcD5/BSGxM2qdJHMxOkxsJ5+Ks6m4lKHSS9+yZ17c=";
  subPackages = ["protoc-gen-openapiv2"];

  meta = with lib; {
    description = "A protoc plugin that generates OpenAPI v2 (Swagger) documents for gRPC services";
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    license = licenses.bsd3;
    maintainers = with maintainers; [];
  };
}
