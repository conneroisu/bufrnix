{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  protobuf,
  jdk,
  ...
}: let
  version = "1.60.0";

  # Platform detection for multi-platform support
  platform =
    if stdenv.isLinux && stdenv.isx86_64
    then "linux-x86_64"
    else if stdenv.isLinux && stdenv.isAarch64
    then "linux-aarch_64"
    else if stdenv.isDarwin && stdenv.isx86_64
    then "osx-x86_64"
    else if stdenv.isDarwin && stdenv.isAarch64
    then "osx-aarch_64"
    else throw "Unsupported platform for grpc-java";
in
  stdenv.mkDerivation {
    pname = "grpc-java";
    inherit version;

    # For multi-platform support
    src = fetchurl {
      url = "https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-java/${version}/protoc-gen-grpc-java-${version}-${platform}.exe";
      sha256 =
        if platform == "linux-x86_64"
        then "12a9z4f04wzs016rz47wbwnywznqqrlrvdpyhsn50j7svbhab64r"
        else if platform == "linux-aarch_64"
        then "05r7a92grp064yid4909r9222xgpdl7xy2dfry77c7q61jqcm7s3"
        else if platform == "osx-x86_64"
        then "1plfvx7k5drh1dvd2zia901acd3anvgj58bfws071vlqk43hqv5v"
        else if platform == "osx-aarch_64"
        then "1plfvx7k5drh1dvd2zia901acd3anvgj58bfws071vlqk43hqv5v"
        else throw "Unknown platform";
    };

    nativeBuildInputs = [makeWrapper];

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      # Install the binary
      install -Dm755 $src $out/bin/protoc-gen-grpc-java

      # The plugin needs to be executable
      chmod +x $out/bin/protoc-gen-grpc-java

      runHook postInstall
    '';

    meta = with lib; {
      description = "gRPC Java protoc plugin";
      homepage = "https://github.com/grpc/grpc-java";
      license = licenses.asl20;
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    };
  }
