import Foundation
import SwiftProtobuf

// Note: The generated protobuf code will be imported here after running bufrnix
// import Example_V1

print("Swift protobuf example")
print("This example will demonstrate protobuf usage once proto files are generated.")
print("")
print("To generate protobuf files:")
print("1. Run 'nix develop' to enter the dev shell")
print("2. Run 'bufrnix_init' to create example proto files")
print("3. Run 'bufrnix' to generate Swift code")
print("4. Uncomment the import and example code below")

// Example usage (uncomment after generating proto files):
/*
// Create an Example message
var example = Example_V1_Example()
example.id = "123"
example.name = "Test Example"
example.value = 42

// Serialize to binary
let binaryData = try example.serializedData()
print("Serialized binary size: \(binaryData.count) bytes")

// Serialize to JSON
let jsonData = try example.jsonUTF8Data()
if let jsonString = String(data: jsonData, encoding: .utf8) {
    print("JSON representation:")
    print(jsonString)
}

// Create a service request
var request = Example_V1_GetExampleRequest()
request.id = "123"

// Create a service response
var response = Example_V1_GetExampleResponse()
response.example = example

print("\nExample message created successfully!")
print("ID: \(example.id)")
print("Name: \(example.name)")
print("Value: \(example.value)")
*/