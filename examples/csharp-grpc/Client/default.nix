{pkgs, ...}:
pkgs.buildDotnetModule {
  pname = "Client";
  version = "1.0.0";

  src = ./../.;

  projectFile = "Client/Client.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
  dotnet-runtime = pkgs.dotnetCorePackages.runtime_8_0;
}
