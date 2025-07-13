package main

import (
	"fmt"
	"log"
	"time"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"

	userv1 "example.com/user/v1"
)

func main() {
	fmt.Println("🔧 Breaking Change Detection Example")
	fmt.Println("====================================")
	
	// Create a new user
	user := &userv1.User{
		Id:        "user123",
		Email:     "alice@example.com",
		Name:      "Alice Johnson",
		Status:    userv1.UserStatus_USER_STATUS_ACTIVE,
		CreatedAt: timestamppb.New(time.Now()),
		LastLogin: timestamppb.New(time.Now().Add(-24 * time.Hour)),
	}

	// Serialize the user
	data, err := proto.Marshal(user)
	if err != nil {
		log.Fatalf("Failed to marshal user: %v", err)
	}

	fmt.Printf("Serialized user data: %d bytes\n", len(data))

	// Deserialize the user
	var deserializedUser userv1.User
	if err := proto.Unmarshal(data, &deserializedUser); err != nil {
		log.Fatalf("Failed to unmarshal user: %v", err)
	}

	fmt.Printf("Deserialized user: %s (%s)\n", 
		deserializedUser.GetName(), 
		deserializedUser.GetEmail())
	
	fmt.Println("\n✅ Proto generation and serialization working correctly!")
	fmt.Println("\nNext steps:")
	fmt.Println("1. Make changes to proto/user/v1/user.proto")
	fmt.Println("2. Commit your changes")
	fmt.Println("3. Run 'nix run' to see breaking change detection in action")
}