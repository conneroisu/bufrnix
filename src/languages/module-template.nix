{
  pkgs,
  config,
  lib,
  cfg ? config.languages.someLanguage,
  ...
}:
# This is a template for language modules.
# Each language module should implement this interface.
{
  # Runtime inputs required for this language's code generation
  runtimeInputs = [
    # packages required for this language
  ];

  # Protoc plugin configuration
  protocPlugins = [
    # Parameters to pass to protoc for this language
  ];

  # Command options for protoc
  commandOptions = [
    # CLI options to pass to the protoc command
  ];

  # Initialization hooks for this language
  initHooks = ''
    # Shell script code to run during initialization
    # Will be included in the bufrnix_init script
  '';

  # Code generation hooks for this language
  generateHooks = ''
    # Shell script code to run during code generation
    # Will be included in the main bufrnix script
  '';
}
