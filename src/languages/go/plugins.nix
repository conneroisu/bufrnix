# Dynamic plugin configuration based on plugins list
{
  pkgs,
  lib,
  cfg ? {},
  ...
}:
with lib; let
  registry = import ./plugin-registry.nix {inherit pkgs lib;};

  # Parse plugin configuration
  parsePlugin = plugin:
    if isString plugin
    then
      # Simple string plugin name
      {
        name = plugin;
        options = (registry.resolvePlugin plugin).options or [];
      }
    else
      # Attribute set with custom options
      {
        name = plugin.plugin;
        options = plugin.opt or (registry.resolvePlugin plugin.plugin).options or [];
      };

  # Get all configured plugins
  configuredPlugins = map parsePlugin (cfg.plugins or []);

  # Resolve plugin info from registry
  resolvePluginInfo = pluginConfig: let
    pluginInfo = registry.resolvePlugin pluginConfig.name;
  in {
    inherit (pluginInfo) package module;
    options = pluginConfig.options;
    name = pluginConfig.name;
  };

  # Get all resolved plugins
  resolvedPlugins = map resolvePluginInfo configuredPlugins;

  # Filter plugins by module type
  pluginsForModule = moduleName:
    filter (p: p.module == moduleName) resolvedPlugins;

  # Check if a module should be enabled based on plugins
  isModuleEnabled = moduleName:
    any (p: p.module == moduleName) resolvedPlugins;

  # Get options for a specific module
  moduleOptions = moduleName: let
    plugins = pluginsForModule moduleName;
  in
    if length plugins > 0
    then (head plugins).options
    else [];

  # Get package for a specific module
  modulePackage = moduleName: let
    plugins = pluginsForModule moduleName;
  in
    if length plugins > 0
    then (head plugins).package
    else null;
in {
  # Export helper functions for use in other modules
  inherit isModuleEnabled moduleOptions modulePackage;

  # Runtime inputs from all plugins
  runtimeInputs =
    filter (p: p != null) (map (p: p.package) resolvedPlugins);

  # Generate status message
  statusMessage =
    if length configuredPlugins > 0
    then "Configured Go plugins: ${concatStringsSep ", " (map (p: p.name) configuredPlugins)}"
    else "No Go plugins configured via 'plugins' option";
}
