{
  pkgs,
  config,
  lib,
  cfg ? config.languages.scala,
  ...
}:
with lib; let
  # ScalaPB package
  scalapbPackage = cfg.package or (pkgs.callPackage ../../packages/scalapb {});
  
  # Scala-specific options
  scalaOptions = cfg.options;
  outputPath = cfg.outputPath;
  
  # Import Scala-specific sub-modules
  grpcModule = import ./grpc.nix {
    inherit pkgs lib;
    cfg = 
      (cfg.grpc or {enable = false;})
      // {
        outputPath = outputPath;
        scalapbPackage = scalapbPackage;
      };
  };
  
  # Combine all sub-modules
  combineModuleAttrs = attr:
    concatLists (catAttrs attr [
      grpcModule
    ]);
in {
  # Runtime dependencies for Scala code generation
  runtimeInputs = [
    pkgs.protobuf # Contains protoc
    scalapbPackage # ScalaPB compiler plugin
    pkgs.jdk # JDK for running ScalaPB
  ] ++ (combineModuleAttrs "runtimeInputs");
  
  # Protoc plugin configuration for Scala
  protocPlugins = [
    "--plugin=protoc-gen-scala=${scalapbPackage}/bin/protoc-gen-scala"
    "--scala_out=${outputPath}"
  ] ++ (optionals (scalaOptions != []) [
    "--scala_opt=${concatStringsSep "," scalaOptions}"
  ]) ++ (combineModuleAttrs "protocPlugins");
  
  # Initialization hook for Scala
  initHooks = ''
    # Create Scala-specific output directory
    mkdir -p "${outputPath}"
    
    # Create build.sbt if enabled
    ${optionalString cfg.generateBuildFile ''
      echo "Creating Scala build.sbt file..."
      cat > "${cfg.outputPath}/build.sbt" <<EOF
      ThisBuild / scalaVersion := "${cfg.scalaVersion}"
      ThisBuild / version      := "${cfg.projectVersion}"
      ThisBuild / organization := "${cfg.organization}"
      
      lazy val root = (project in file("."))
        .settings(
          name := "${cfg.projectName}",
          libraryDependencies ++= Seq(
            "com.thesamet.scalapb" %% "scalapb-runtime" % scalapb.compiler.Version.scalapbVersion % "protobuf",
            ${optionalString cfg.grpc.enable ''
              "io.grpc" % "grpc-netty" % scalapb.compiler.Version.grpcJavaVersion,
              "com.thesamet.scalapb" %% "scalapb-runtime-grpc" % scalapb.compiler.Version.scalapbVersion,
            ''}
            ${optionalString cfg.json.enable ''
              "com.thesamet.scalapb" %% "scalapb-json4s" % "${cfg.json.json4sVersion}",
            ''}
            ${optionalString cfg.validate.enable ''
              "com.thesamet.scalapb" %% "scalapb-validate-core" % scalapb.validate.compiler.BuildInfo.version % "protobuf",
            ''}
          )
        )
      
      // Add generated sources to the project
      Compile / sourceDirectories += file("${outputPath}")
      EOF
    ''}
    
    # Create project/plugins.sbt if enabled
    ${optionalString cfg.generateBuildFile ''
      mkdir -p "${cfg.outputPath}/project"
      cat > "${cfg.outputPath}/project/plugins.sbt" <<EOF
      addSbtPlugin("com.thesamet" % "sbt-protoc" % "${cfg.sbtProtocVersion}")
      
      libraryDependencies += "com.thesamet.scalapb" %% "compilerplugin" % "${cfg.scalapbVersion}"
      ${optionalString cfg.validate.enable ''
        libraryDependencies += "com.thesamet.scalapb" %% "scalapb-validate-codegen" % scalapb.validate.compiler.BuildInfo.version
      ''}
      EOF
    ''}
    
    # Create project/build.properties if enabled
    ${optionalString cfg.generateBuildFile ''
      cat > "${cfg.outputPath}/project/build.properties" <<EOF
      sbt.version=${cfg.sbtVersion}
      EOF
    ''}
  '' + concatStrings (catAttrs "initHooks" [
    grpcModule
  ]);
  
  # Code generation hook for Scala
  generateHooks = ''
    # Scala-specific code generation steps
    echo "Generating Scala code with ScalaPB..."
    
    # Ensure output directory exists
    mkdir -p ${outputPath}
    
    # Post-process if needed
    ${optionalString cfg.generatePackageObject ''
      echo "Generating package objects..."
      find ${outputPath} -type f -name "*.scala" | while read file; do
        # Extract package name from file
        pkg=$(grep -E "^package " "$file" | head -1 | sed 's/package //' | tr -d ' ')
        if [ -n "$pkg" ]; then
          dir=$(dirname "$file")
          pkgfile="$dir/package.scala"
          if [ ! -f "$pkgfile" ]; then
            echo "package object $(basename "$pkg") {}" > "$pkgfile"
          fi
        fi
      done
    ''}
  '' + concatStrings (catAttrs "generateHooks" [
    grpcModule
  ]);
}