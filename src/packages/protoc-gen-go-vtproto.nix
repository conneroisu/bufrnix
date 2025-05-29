{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule rec {
  pname = "protoc-gen-go-vtproto";
  version = "0.6.0";

  src = pkgs.fetchFromGitHub {
    owner = "planetscale";
    repo = "vtprotobuf";
    rev = "v${version}";
    sha256 = "sha256-iNgDZRjmzFqgtkTiZdQ2f3mS8L6RiqnSJJJP2p8/RJE=";
  };

  vendorHash = "sha256-JpSVO8h7+StLG9/dJQkmrIlh9zIHABoqP7jkDzHT18w=";
  subPackages = ["cmd/protoc-gen-go-vtproto"];

  meta = with lib; {
    description = "A protocol buffer compiler plugin that generates Go code with vtprotobuf optimizations";
    homepage = "https://github.com/planetscale/vtprotobuf";
    license = licenses.bsd3;
    maintainers = with maintainers; [];
  };
}

