{
  description = "Protobuf Compiler/Codegen Declaratively from Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs: let
    eachSystem = f:
      builtins.listToAttrs (
        map
        (system: {
          name = system;
          value = f system;
        })
        [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ]
      );
    treefmtEval = eachSystem (
      system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [];
        };
      in
        inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            buf.enable = true;
            prettier.enable = true;
            prettier.includes = [
              "**/*.md"
              "**/*.mdx"
              "**/*.ts"
              "**/*.tsx"
              "**/*.json"
            ];
            yamlfmt.enable = true;
          };
        }
    );
  in {
    # Flake formatter output for `nix fmt`
    formatter = eachSystem (
      system:
        treefmtEval.${system}.config.build.wrapper
    );

    # Add checks
    checks = eachSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [];
      };
    in {
      # formatting = treefmtEval.${system}.config.build.check inputs.self;

      # Check that all example flake.nix files have commented bufrnix URL
      example-linter =
        pkgs.runCommand "example-linter" {
          nativeBuildInputs = [pkgs.bash pkgs.gnugrep pkgs.findutils];
          src = inputs.self;
        } ''
          # Copy source to a writable location
          cp -r $src ./source
          chmod -R +w ./source
          cd ./source

          # Run the linter directly (inline the check)
          REQUIRED_COMMENT="# bufrnix.url = \"github:conneroisu/bufrnix\""
          exit_code=0
          checked_files=0

          echo "🔍 Checking example flake.nix files for commented bufrnix origin URL..."
          echo "Required comment: $REQUIRED_COMMENT"

          # Find all flake.nix files in examples directory
          while IFS= read -r -d ''' flake_file; do
              checked_files=$((checked_files + 1))
              relative_path="''${flake_file#./}"

              if grep -qF "$REQUIRED_COMMENT" "$flake_file"; then
                  echo "✅ $relative_path - has required comment"
              else
                  echo "❌ $relative_path - missing required comment"
                  exit_code=1
              fi
          done < <(find ./examples -name "flake.nix" -type f -print0)

          echo
          echo "📊 Checked $checked_files files"

          if [ $exit_code -eq 0 ]; then
              echo "🎉 All example flake.nix files have the required commented bufrnix URL!"
              touch $out
          else
              echo "💥 Some example flake.nix files are missing the required commented bufrnix URL."
              exit 1
          fi
        '';
    });

    devShells = eachSystem (
      system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [];
        };
        scripts = {
          dx = {
            exec = ''$EDITOR "$(git rev-parse --show-toplevel)"/flake.nix'';
            description = "Edit flake.nix";
          };
          lint = {
            exec = ''
              REPO_ROOT="$(git rev-parse --show-toplevel)"
              statix check "$REPO_ROOT"/flake.nix
              deadnix "$REPO_ROOT"/flake.nix
            '';
            deps = with pkgs; [statix deadnix];
            description = "Lint nix files";
          };
        };
        scriptPackages =
          pkgs.lib.mapAttrs
          (
            name: script:
              pkgs.writeShellApplication {
                inherit name;
                text = script.exec;
                runtimeInputs = script.deps or [];
              }
          )
          scripts;
      in {
        default = pkgs.mkShell {
          shellHook = ''
            export REPO_ROOT=$(git rev-parse --show-toplevel)
          '';
          packages = with pkgs;
            [
              # Nix
              alejandra
              nixd
              statix
              nixdoc
              # Add the formatter to the devShell
              treefmtEval.${system}.config.build.wrapper
              git-bug
              # Python for package update scripts
              python3
              act
            ]
            ++ builtins.attrValues scriptPackages;
        };
      }
    );

    lib = {
      mkBufrnixPackage = {
        pkgs,
        self ? null,
        config ? {},
        ...
      }:
        import "${inputs.self}/src/lib/mkBufrnix.nix" {
          inherit pkgs self config;
        };
    };
  };
}
