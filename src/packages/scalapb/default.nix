{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "scalapb";
  version = "1.0.0-alpha.1";

  # Use the universal JAR distribution that works on all platforms
  src = pkgs.fetchurl {
    url = "https://github.com/scalapb/ScalaPB/releases/download/v${version}/scalapbc-${version}.zip";
    sha256 = "sha256-St4WLUVv6mfwPVLdLrfyzlRWKKbIRZkIWoGjw9vP5TM=";
  };

  nativeBuildInputs = with pkgs; [
    unzip
    makeWrapper
  ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/scalapb
    mkdir -p $out/bin

    # Copy all files
    cp -r scalapbc-${version}/* $out/share/scalapb/
    chmod +x $out/share/scalapb/bin/scalapbc || true

    # The main JAR is scalapbc-*.jar in the lib directory
    main_jar="$out/share/scalapb/lib/com.thesamet.scalapb.scalapbc-${version}.jar"

    # Create wrapper script for protoc-gen-scala
    # Note: When used as protoc plugin, it expects proto input on stdin and outputs to stdout
    makeWrapper ${pkgs.jre}/bin/java $out/bin/protoc-gen-scala \
      --add-flags "-cp '$out/share/scalapb/lib/*' scalapb.ScalaPbCodeGenerator"

    # Also create protoc-gen-scalapb alias for compatibility
    ln -s $out/bin/protoc-gen-scala $out/bin/protoc-gen-scalapb

    # Create scalapbc wrapper for standalone usage
    makeWrapper ${pkgs.jre}/bin/java $out/bin/scalapbc \
      --add-flags "-jar $main_jar"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Protocol buffer compiler plugin for Scala";
    homepage = "https://scalapb.github.io/";
    license = licenses.asl20;
    maintainers = with maintainers; [];
    platforms = platforms.all; # Works on all platforms with Java
  };
}
