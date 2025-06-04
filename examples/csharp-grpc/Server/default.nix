{pkgs, ...}:
pkgs.buildDotnetModule {
  pname = "Server";
  version = "1.0.0";

  src = ./../.;

  projectFile = "Server/Server.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
  dotnet-runtime = pkgs.dotnetCorePackages.aspnetcore_8_0;
}
