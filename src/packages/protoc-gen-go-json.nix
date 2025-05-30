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
    sha256 = "sha256-g3Rc9cpONI6+FiXcMG9H8go6J7i+hsvcQG8OREMqaKU=";
  };

  vendorHash = "sha256-8G8u5gXOcFiqOKwdrj8RKNp8l8X/lLIDkudginm7JPw=";

  meta = with lib; {
    description = "A protoc plugin that generates Go code with JSON marshaling/unmarshaling methods";
    homepage = "https://github.com/mfridman/protoc-gen-go-json";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
