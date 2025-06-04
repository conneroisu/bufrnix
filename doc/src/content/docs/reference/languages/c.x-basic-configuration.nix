{
  inputs = {
    bufrnix.url = "github:conneroisu/bufr.nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self;} {
      imports = [
        inputs.bufrnix.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        bufrnix.languages.c = {
          enable = true;
          outputPath = "gen/c";

          # Choose your implementation
          protobuf-c.enable = true; # For general C applications
          # OR
          nanopb.enable = true; # For embedded systems
        };
      };
    };
}
