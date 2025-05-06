{
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    lib,
    system,
    ...
  }: {
    packages.docs = pkgs.buildNpmPackage {
      pname = "docs";
      version = "0.1.0";

      inherit (pkgs) nodejs;

      src = ./.;

      buildInputs = [
        pkgs.vips
      ];

      nativeBuildInputs = [
        pkgs.pkg-config
      ];
      npmBuildScript = "build";
      installPhase = ''
        runHook preInstall
        cp -pr --reflink=auto dist $out/
        runHook postInstall
      '';

      npmDepsHash = "sha256-Y0xefbAuGy5wbwLOmW9lXXwHh3Ype7TnnPh8EGNL6/Y=";
    };
  };
}
