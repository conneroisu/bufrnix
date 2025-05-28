# Package derivation for protoc-gen-struct-transformer
# This would normally be in nixpkgs, but we include it here for convenience
{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "protoc-gen-struct-transformer";
  version = "1.0.8"; # Latest release as of 2024

  src = fetchFromGitHub {
    owner = "bold-commerce";
    repo = "protoc-gen-struct-transformer";
    rev = "v${version}";
    sha256 = "sha256-xRxice4t609Gcum6ce3KtRkjISStW7D1+5Tpyl3ogB4=";
  };

  vendorHash = "sha256-1pBVy9Bo8PTI4AbQe2fpK4dFOVhNf1PcsfBo8bQ9kak=";

  meta = with lib; {
    description = "Transformation functions generator for Protocol Buffers - Go struct transformer";
    homepage = "https://github.com/bold-commerce/protoc-gen-struct-transformer";
    license = licenses.mit;
    maintainers = with maintainers; [connerohnesorge];
    mainProgram = "protoc-gen-struct-transformer";
  };
}
