{
  lib,
  pkgs,
  ...
}: let
  python = pkgs.python313;
  pythonPackages = python.pkgs;
in
  pythonPackages.buildPythonPackage {
    pname = "betterproto";
    version = "2.0.0b4";
    pyproject = true;
    build-system = [pythonPackages.poetry-core];

    src = pkgs.fetchFromGitHub {
      owner = "danielgtaylor";
      repo = "python-betterproto";
      rev = "6a65ca94bc5a4131c3110514947a25e850633fbc";
      sha256 = "sha256-0FE4unwTwQEmUegndQ2z7A5eiBzXTOruot3lrV3UrLg=";
    };

    # The dependencies as provided in the package's requirements.
    propagatedBuildInputs = [
      pythonPackages.setuptools # setuptools>=65
    ];

    runTimeDependencies = [
      pythonPackages.grpclib
      pythonPackages.python-dateutil
      pythonPackages.typing-extensions
      pythonPackages.black
      pythonPackages.isort
      pythonPackages.jinja2
      pythonPackages.ruff
    ];

    dependencies = [
      pythonPackages.grpclib
      pythonPackages.python-dateutil
      pythonPackages.typing-extensions
      pythonPackages.black
      pythonPackages.isort
      pythonPackages.jinja2
      pythonPackages.ruff
    ];

    runtimeDependencies = [
      pythonPackages.grpclib
      pythonPackages.python-dateutil
      pythonPackages.typing-extensions
      pythonPackages.black
      pythonPackages.isort
      pythonPackages.jinja2
      pythonPackages.ruff
    ];

    noCheck = true;

    checkPhase = ''
      python -c "import betterproto"
    '';

    meta = with lib; {
      description = "A better Python Protocol Buffers library";
      homepage = "https://github.com/danielgtaylor/python-betterproto";
      license = licenses.mit;
      maintainers = [
        connerohnesorge
        conneroisu
      ];
    };
  }
