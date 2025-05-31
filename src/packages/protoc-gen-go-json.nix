{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule rec {
  pname = "protoc-gen-go-json";
  version = "1.4.0";

  src = pkgs.fetchFromGitHub {
    owner = "mfridman";
    repo = "protoc-gen-go-json";
    rev = "v${version}";
    sha256 = "sha256-qgYW12nsDPpaDnhkMS+4yaAeV2pHOdYg97SbA6emnkQ=";
  };

  vendorHash = "sha256-80HXbpa4ZZDPyMHPHUYzGqZ8eYE9oJC8uvpg5I9TxKw=";

  meta = with lib; {
    description = "A protoc plugin that generates Go code with JSON marshaling/unmarshaling methods";
    homepage = "https://github.com/mfridman/protoc-gen-go-json";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
