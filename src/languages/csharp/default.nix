{
  pkgs,
  config,
  lib,
  cfg ? config.languages.csharp,
  ...
}:
with lib; let
  # Define output path and options
  outputPath = cfg.outputPath;
  csharpOptions = cfg.options;

  # Import C#-specific sub-modules
  grpcModule = import ./grpc.nix {
    inherit pkgs lib;
    cfg =
      (cfg.grpc or {enable = false;})
      // {
        outputPath = outputPath;
      };
  };

  # Combine all sub-modules
  combineModuleAttrs = attr:
    concatLists (catAttrs attr [
      grpcModule
    ]);
in {
  # Runtime dependencies for C# code generation
  runtimeInputs =
    [
      pkgs.protobuf
      cfg.sdk
    ]
    ++ (combineModuleAttrs "runtimeInputs");

  # Protoc plugin configuration for C#
  protocPlugins =
    [
      "--csharp_out=${outputPath}"
    ]
    ++ (optionals (csharpOptions != []) [
      "--csharp_opt=${concatStringsSep "," csharpOptions}"
    ])
    ++ (combineModuleAttrs "protocPlugins");

  # Initialization hook for C#
  initHooks =
    ''
      # Create C#-specific directories
      mkdir -p "${outputPath}"
      
      # Create .csproj file for generated code if enabled
      ${optionalString cfg.generateProjectFile ''
        echo "Creating C# project file..."
        cat > "${outputPath}/${cfg.projectName}.csproj" <<EOF
        <Project Sdk="Microsoft.NET.Sdk">
          <PropertyGroup>
            <TargetFramework>${cfg.targetFramework}</TargetFramework>
            <LangVersion>${cfg.langVersion}</LangVersion>
            <Nullable>${if cfg.nullable then "enable" else "disable"}</Nullable>
            <GeneratePackageOnBuild>${if cfg.generatePackageOnBuild then "true" else "false"}</GeneratePackageOnBuild>
            ${optionalString (cfg.packageId != "") "<PackageId>${cfg.packageId}</PackageId>"}
            ${optionalString (cfg.packageVersion != "") "<Version>${cfg.packageVersion}</Version>"}
            ${optionalString (cfg.namespace != "") "<RootNamespace>${cfg.namespace}</RootNamespace>"}
          </PropertyGroup>
          <ItemGroup>
            <PackageReference Include="Google.Protobuf" Version="${cfg.protobufVersion}" />
            ${optionalString cfg.grpc.enable ''
              <PackageReference Include="Grpc.Net.Client" Version="${cfg.grpc.grpcVersion}" />
              <PackageReference Include="Grpc.Core.Api" Version="${cfg.grpc.grpcCoreVersion}" />
            ''}
          </ItemGroup>
        </Project>
        EOF
      ''}
    ''
    + concatStrings (catAttrs "initHooks" [
      grpcModule
    ]);

  # Code generation hook for C#
  generateHooks =
    ''
      # C#-specific code generation steps
      echo "Generating C# code..."
      mkdir -p ${outputPath}
      
      # Post-process generated files if needed
      ${optionalString (cfg.fileExtension != ".cs") ''
        echo "Renaming generated files to use ${cfg.fileExtension} extension..."
        find ${outputPath} -name "*.cs" -exec bash -c 'mv "$0" "''${0%.cs}${cfg.fileExtension}"' {} \;
      ''}
      
      # Generate AssemblyInfo.cs if enabled
      ${optionalString cfg.generateAssemblyInfo ''
        echo "Generating AssemblyInfo.cs..."
        cat > "${outputPath}/AssemblyInfo.cs" <<EOF
        using System.Reflection;
        using System.Runtime.CompilerServices;
        
        [assembly: AssemblyTitle("${cfg.projectName}")]
        [assembly: AssemblyDescription("Generated Protocol Buffer code")]
        [assembly: AssemblyConfiguration("")]
        [assembly: AssemblyCompany("")]
        [assembly: AssemblyProduct("${cfg.projectName}")]
        [assembly: AssemblyCopyright("")]
        [assembly: AssemblyTrademark("")]
        [assembly: AssemblyVersion("${cfg.assemblyVersion}")]
        [assembly: AssemblyFileVersion("${cfg.assemblyVersion}")]
        EOF
      ''}
    ''
    + concatStrings (catAttrs "generateHooks" [
      grpcModule
    ]);
}