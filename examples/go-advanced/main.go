package main

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	examplev1 "github.com/example/proto/gen/go/example/v1"
	"google.golang.org/protobuf/types/known/timestamppb"
)

func main() {
	// Create a user using the generated types
	user := &examplev1.User{
		Id:    "user-123",
		Email: "user@example.com",
		Name:  "Test User",
		Roles: []string{"admin", "developer"},
		Metadata: map[string]string{
			"department": "engineering",
			"team":       "platform",
		},
		CreatedAt: timestamppb.New(time.Now()),
		UpdatedAt: timestamppb.New(time.Now()),
		Profile: &examplev1.User_Profile{
			Bio:       "A passionate developer",
			AvatarUrl: "https://example.com/avatar.png",
			Interests: []string{"golang", "protobuf", "performance"},
		},
	}

	// Demonstrate vtprotobuf performance
	fmt.Println("=== VTProtobuf Performance Demo ===")
	
	// Using vtprotobuf's optimized marshal (if vtprotobuf is enabled)
	data, err := user.MarshalVT()
	if err != nil {
		log.Fatalf("Failed to marshal: %v", err)
	}
	fmt.Printf("Marshaled size: %d bytes\n", len(data))
	
	// Using vtprotobuf's optimized unmarshal
	decoded := &examplev1.User{}
	if err := decoded.UnmarshalVT(data); err != nil {
		log.Fatalf("Failed to unmarshal: %v", err)
	}
	
	// Demonstrate JSON integration (if go-json plugin is enabled)
	fmt.Println("\n=== JSON Integration Demo ===")
	
	// Standard JSON marshaling works seamlessly
	jsonData, err := json.MarshalIndent(user, "", "  ")
	if err != nil {
		log.Fatalf("Failed to marshal to JSON: %v", err)
	}
	fmt.Printf("JSON representation:\n%s\n", jsonData)
	
	// JSON unmarshaling also works
	var jsonUser examplev1.User
	if err := json.Unmarshal(jsonData, &jsonUser); err != nil {
		log.Fatalf("Failed to unmarshal from JSON: %v", err)
	}
	
	fmt.Println("\n=== Generated Features ===")
	fmt.Printf("User ID: %s\n", decoded.GetId())
	fmt.Printf("User Email: %s\n", decoded.GetEmail())
	fmt.Printf("Roles: %v\n", decoded.GetRoles())
	fmt.Printf("Profile Bio: %s\n", decoded.GetProfile().GetBio())
	
	// If using memory pooling (vtprotobuf feature)
	// user.ReturnToVTPool() // Return to pool when done
	
	fmt.Println("\n✅ All features working correctly!")
	fmt.Println("\nNote: This example demonstrates:")
	fmt.Println("- VTProtobuf's high-performance marshaling")
	fmt.Println("- Seamless JSON integration")
	fmt.Println("- gRPC service stubs (see generated UserServiceClient)")
	fmt.Println("- OpenAPI docs (check proto/gen/openapi/)")
}