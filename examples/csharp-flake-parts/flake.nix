{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # bufrnix.url = "github:conneroisu/bufrnix";
    bufrnix = {
      url = "path:../..";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    bufrnix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        protoGen = bufrnix.lib.mkBufrnixPackage {
          inherit pkgs;
          config = {
            root = ./proto;
            languages.csharp = {
              enable = true;
              namespace = "ExampleProtos";
              generateProjectFile = true;
              projectName = "ExampleProtos";
            };
          };
        };

        app = pkgs.buildDotnetModule {
          pname = "csharp-proto-example";
          version = "1.0.0";
          src = ./.;
          projectFile = "CSharpExample.csproj";
          nugetDeps = ./deps.json;
          dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
          dotnet-runtime = pkgs.dotnetCorePackages.runtime_8_0;
        };
      in {
        packages = {
          default = protoGen;
          proto = protoGen;
          inherit app;
        };

        apps.app = {
          type = "app";
          program = "${app}/bin/CSharpExample";
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            dotnetCorePackages.sdk_8_0
            protobuf
            grpc
            nuget-to-json
          ];
          shellHook = ''
            echo "C# Proto Example Development Shell"
            echo "Run 'nix run' to generate proto code"
            echo "Run 'nix run .#app' or 'dotnet run' to run the application"
          '';
        };
      };
    };
}
