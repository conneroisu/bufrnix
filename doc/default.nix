{mkBunDerivation, ...}:
mkBunDerivation {
  pname = "bun2nix-example";
  version = "1.0.0";

  src = ./.;

  bunNix = ./bun.nix;

  index = "index.ts";
}
