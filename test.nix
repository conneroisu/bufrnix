with import <nixpkgs> {};
(php83.buildEnv {
  extensions = { all, enabled }: enabled ++ (with all; [
    mbstring iconv curl tokenizer ctype fileinfo dom intl zip sodium openssl
  ]);
})
