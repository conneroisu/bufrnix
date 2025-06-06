package main

import (
	"context"
	"fmt"
	"log"

	pb "github.com/example/flakeparts/proto/gen/go/example/v1"
	"google.golang.org/grpc"
)

// server implements the UserService
type server struct {
	pb.UnimplementedUserServiceServer
	users map[string]*pb.User
}

// CreateUser creates a new user
func (s *server) CreateUser(ctx context.Context, req *pb.CreateUserRequest) (*pb.CreateUserResponse, error) {
	user := &pb.User{
		Id:    fmt.Sprintf("user_%d", len(s.users)+1),
		Name:  req.Name,
		Email: req.Email,
		Age:   req.Age,
	}
	
	s.users[user.Id] = user
	
	return &pb.CreateUserResponse{
		User: user,
	}, nil
}

// GetUser retrieves a user by ID
func (s *server) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.GetUserResponse, error) {
	user, exists := s.users[req.Id]
	if !exists {
		return nil, fmt.Errorf("user not found: %s", req.Id)
	}
	
	return &pb.GetUserResponse{
		User: user,
	}, nil
}

func main() {
	// Create a gRPC server (commented out to avoid port conflicts in example)
	// _, err := net.Listen("tcp", ":50051")
	// if err != nil {
	// 	log.Fatalf("failed to listen: %v", err)
	// }

	s := grpc.NewServer()
	userServer := &server{
		users: make(map[string]*pb.User),
	}
	
	pb.RegisterUserServiceServer(s, userServer)

	fmt.Println("gRPC server listening on :50051")
	fmt.Println("Example demonstrates flake-parts integration with Bufrnix")
	
	// Create a test user for demonstration
	testUser, err := userServer.CreateUser(context.Background(), &pb.CreateUserRequest{
		Name:  "Alice Johnson",
		Email: "alice@example.com",
		Age:   30,
	})
	if err != nil {
		log.Fatalf("failed to create test user: %v", err)
	}
	
	fmt.Printf("Created test user: %+v\n", testUser.User)
	
	// Retrieve the test user
	retrievedUser, err := userServer.GetUser(context.Background(), &pb.GetUserRequest{
		Id: testUser.User.Id,
	})
	if err != nil {
		log.Fatalf("failed to get test user: %v", err)
	}
	
	fmt.Printf("Retrieved test user: %+v\n", retrievedUser.User)
	fmt.Println("Flake-parts example completed successfully!")

	// Note: In a real application, you would call s.Serve(lis) here
	// For this example, we just demonstrate the functionality
}