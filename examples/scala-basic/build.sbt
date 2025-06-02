ThisBuild / scalaVersion := "3.3.3"
ThisBuild / version      := "0.1.0"
ThisBuild / organization := "com.example.protobuf"

lazy val root = (project in file("."))
  .settings(
    name := "scala-proto-example",
    libraryDependencies ++= Seq(
      "com.thesamet.scalapb" %% "scalapb-runtime" % "0.11.17"
    ),
    Compile / unmanagedSourceDirectories += baseDirectory.value / "gen" / "scala"
  )