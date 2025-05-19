let
  pkgs = import <nixpkgs> {};
  
  # Mock lib functions
  mockLib = {
    optionals = cond: list: if cond then list else [];
    optionalString = cond: str: if cond then str else "";
    concatLists = pkgs.lib.lists.concatLists;
    concatStrings = pkgs.lib.strings.concatStrings;
    catAttrs = pkgs.lib.attrsets.catAttrs;
  };
  
  # Import the PHP language module
  phpModule = import ./src/languages/php {
    inherit pkgs;
    lib = mockLib;
    config = {
      languages.php = {
        enable = true;
        outputPath = "gen/php";
        twirp = {
          enable = true;
        };
      };
    };
    cfg = {
      enable = true;
      outputPath = "gen/php";
      twirp = {
        enable = true;
      };
    };
  };
in
  # Return the file paths
  builtins.trace "PHP module structure:" phpModule