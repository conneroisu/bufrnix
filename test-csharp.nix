# Test for C# language support
{ pkgs ? import <nixpkgs> {} }:

let
  bufrnix = import ./. { inherit pkgs; };
  
  # Test basic C# generation
  basicTest = bufrnix.lib.mkBufrnix {
    root = ./examples/csharp-basic/proto;
    languages = {
      csharp = {
        enable = true;
        namespace = "TestProtos";
        generateProjectFile = true;
      };
    };
  };
  
  # Test C# with gRPC
  grpcTest = bufrnix.lib.mkBufrnix {
    root = ./examples/csharp-grpc/proto;
    languages = {
      csharp = {
        enable = true;
        namespace = "TestGrpcProtos";
        generateProjectFile = true;
        grpc = {
          enable = true;
        };
      };
    };
  };
  
in pkgs.stdenv.mkDerivation {
  name = "bufrnix-csharp-test";
  
  buildInputs = [ basicTest grpcTest ];
  
  buildCommand = ''
    echo "Testing C# protobuf generation..."
    
    # Test basic generation
    echo "Running basic C# test..."
    ${basicTest}/bin/bufrnix
    
    # Check generated files exist
    test -f gen/csharp/Person.cs || (echo "Person.cs not generated!" && exit 1)
    test -f gen/csharp/GeneratedProtos.csproj || (echo "Project file not generated!" && exit 1)
    
    echo "Running gRPC C# test..."
    ${grpcTest}/bin/bufrnix
    
    # Check gRPC files exist
    test -f gen/csharp/Greeter.cs || (echo "Greeter.cs not generated!" && exit 1)
    test -f gen/csharp/GreeterGrpc.cs || (echo "GreeterGrpc.cs not generated!" && exit 1)
    
    echo "All C# tests passed!"
    touch $out
  '';
}