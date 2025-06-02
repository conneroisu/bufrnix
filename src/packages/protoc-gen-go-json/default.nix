{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule rec {
  pname = "protoc-gen-go-json";
  version = "1.5.0";

  src = pkgs.fetchFromGitHub {
    owner = "mfridman";
    repo = "protoc-gen-go-json";
    rev = "v${version}";
    sha256 = "sha256-3NzQwJnFofHxauz55uzhRWFaCE5OK+tegVvtYioTxvY=";
  };

  vendorHash = "sha256-xe5Sm+4dTDY8JqYX9+oXAbAjOtbHhURTTJb/ubwv/KA=";

  meta = with lib; {
    description = "A protoc plugin that generates Go code with JSON marshaling/unmarshaling methods";
    homepage = "https://github.com/mfridman/protoc-gen-go-json";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
