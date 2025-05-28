{
  pkgs,
  config,
  lib,
  cfg ? config.languages.doc,
  ...
}:
with lib; let
  cfg = config.languages.doc;

  # Helper to convert Nix attrs to YAML frontmatter
  attrsToYaml = attrs:
    concatStringsSep "\n" (mapAttrsToList (
        k: v:
          if isString v
          then "${k}: \"${v}\""
          else if isBool v
          then "${k}: ${
            if v
            then "true"
            else "false"
          }"
          else if isInt v
          then "${k}: ${toString v}"
          else "${k}: ${builtins.toJSON v}"
      )
      attrs);

  # Template paths
  mdxTemplatePath = "${./templates/mdx.mustache}";

  # Build the doc_opt string based on format and configuration
  docOptions =
    if cfg.format == "mdx"
    then
      # For MDX, use our custom template
      "${mdxTemplatePath},${
        if cfg.mdx.enable
        then cfg.mdx.outputPath
        else cfg.outputPath
      }/${
        if cfg.mdx.enable
        then cfg.mdx.outputFile
        else cfg.outputFile
      }"
    else if cfg.customTemplate != null
    then
      # Use custom template if provided
      "${cfg.customTemplate},${cfg.outputPath}/${cfg.outputFile}"
    else if cfg.options == []
    then
      # Default behavior
      "${cfg.format},${cfg.outputPath}/${cfg.outputFile}"
    else
      # Use provided options
      concatStringsSep "," cfg.options;

  # Generate MDX-specific hooks if enabled
  mdxHooks = optionalString (cfg.format == "mdx" || cfg.mdx.enable) ''
    # Create MDX output directory
    mkdir -p "${cfg.mdx.outputPath}"

    # Prepare template variables for MDX
    export MDX_TITLE="${cfg.mdx.title}"
    export MDX_DESCRIPTION="${cfg.mdx.description}"

    echo "Generating MDX documentation for Astro site..."
    echo "Output: ${cfg.mdx.outputPath}/${cfg.mdx.outputFile}"
  '';

  # Standard hooks for other formats
  standardHooks = optionalString (cfg.format != "mdx" && !cfg.mdx.enable) ''
    mkdir -p "${cfg.outputPath}"
    echo "Generating ${cfg.format} documentation to ${cfg.outputPath}/${cfg.outputFile}"
  '';
in {
  runtimeInputs = [
    cfg.package
  ];

  protocPlugins = [
    "--doc_out=${
      if cfg.format == "mdx" || cfg.mdx.enable
      then cfg.mdx.outputPath
      else cfg.outputPath
    }"
    "--doc_opt=${docOptions}"
  ];

  commandOptions = [];

  initHooks = ''
    echo "Initializing documentation generation..."
    ${mdxHooks}
    ${standardHooks}
  '';

  generateHooks = ''
    # Post-processing for MDX files
    ${optionalString (cfg.format == "mdx" || cfg.mdx.enable) ''
      # Add frontmatter processing if needed
      if [ -f "${cfg.mdx.outputPath}/${cfg.mdx.outputFile}" ]; then
        # Create a temporary file with enhanced frontmatter
        temp_file=$(mktemp)

        # Write custom frontmatter
        echo "---" > "$temp_file"
        echo "title: \"${cfg.mdx.title}\"" >> "$temp_file"
        echo "description: \"${cfg.mdx.description}\"" >> "$temp_file"
        ${optionalString (cfg.mdx.frontmatter != {}) ''
        ${concatStringsSep "\n" (mapAttrsToList (
            k: v: ''echo "${k}: ${
                if isString v
                then "\"${v}\""
                else builtins.toJSON v
              }" >> "$temp_file"''
          )
          cfg.mdx.frontmatter)}
      ''}
        echo "---" >> "$temp_file"
        echo "" >> "$temp_file"

        # Skip the existing frontmatter in the generated file and append the rest
        sed '1,/^---$/d; /^---$/,$d' "${cfg.mdx.outputPath}/${cfg.mdx.outputFile}" | sed '1d' >> "$temp_file"

        # Replace the original file
        mv "$temp_file" "${cfg.mdx.outputPath}/${cfg.mdx.outputFile}"

        echo "Enhanced MDX file with custom frontmatter"
      fi
    ''}

    ${standardHooks}
  '';
}
