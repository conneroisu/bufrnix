package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"
	"sync"
	"time"

	pb "github.com/conneroisu/bufrnix/examples/simple-flake/proto/gen/go/simple/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/reflection"
)

// server implements the UserService server
type server struct {
	pb.UnimplementedUserServiceServer
	mu    sync.RWMutex
	users map[string]*pb.User
}

// NewServer creates a new UserService server
func NewServer() *server {
	return &server{
		users: make(map[string]*pb.User),
	}
}

// CreateUser implements the CreateUser RPC
func (s *server) CreateUser(ctx context.Context, req *pb.CreateUserRequest) (*pb.CreateUserResponse, error) {
	if req.User == nil {
		return &pb.CreateUserResponse{
			Success: false,
			Error:   "user is required",
		}, nil
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	// Check if user already exists
	if _, exists := s.users[req.User.Id]; exists {
		return &pb.CreateUserResponse{
			Success: false,
			Error:   fmt.Sprintf("user with ID %s already exists", req.User.Id),
		}, nil
	}

	// Store the user
	s.users[req.User.Id] = req.User
	log.Printf("Created user: %s", req.User.Name)

	return &pb.CreateUserResponse{
		User:    req.User,
		Success: true,
	}, nil
}

// GetUser implements the GetUser RPC
func (s *server) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.GetUserResponse, error) {
	if req.UserId == "" {
		return &pb.GetUserResponse{
			Success: false,
			Error:   "user_id is required",
		}, nil
	}

	s.mu.RLock()
	defer s.mu.RUnlock()

	user, exists := s.users[req.UserId]
	if !exists {
		return &pb.GetUserResponse{
			Success: false,
			Error:   fmt.Sprintf("user with ID %s not found", req.UserId),
		}, nil
	}

	return &pb.GetUserResponse{
		User:    user,
		Success: true,
	}, nil
}

// runServer starts the gRPC server
func runServer(port string) {
	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterUserServiceServer(s, NewServer())
	
	// Register reflection service on gRPC server (useful for debugging with tools like grpcurl)
	reflection.Register(s)

	log.Printf("Server listening on %s", port)
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

// runClient demonstrates client usage
func runClient(serverAddr string) {
	// Create a connection to the server
	conn, err := grpc.Dial(serverAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()

	// Create a UserService client
	client := pb.NewUserServiceClient(conn)

	// Create a context with timeout
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	// Example 1: Create a user
	createReq := &pb.CreateUserRequest{
		User: &pb.User{
			Id:     "user123",
			Name:   "John Doe",
			Email:  "john.doe@example.com",
			Age:    30,
			Roles:  []string{"admin", "user"},
			Status: pb.UserStatus_ACTIVE,
			Addresses: []*pb.User_Address{
				{
					Street:  "123 Main St",
					City:    "Springfield",
					State:   "IL",
					Zip:     "62701",
					Country: "USA",
				},
			},
		},
	}

	createResp, err := client.CreateUser(ctx, createReq)
	if err != nil {
		log.Fatalf("could not create user: %v", err)
	}

	if createResp.Success {
		log.Printf("User created successfully: %s", createResp.User.Name)
	} else {
		log.Printf("Failed to create user: %s", createResp.Error)
	}

	// Example 2: Get the user we just created
	getReq := &pb.GetUserRequest{
		UserId: "user123",
	}

	getResp, err := client.GetUser(ctx, getReq)
	if err != nil {
		log.Fatalf("could not get user: %v", err)
	}

	if getResp.Success {
		log.Printf("Retrieved user: %s (email: %s, age: %d)", 
			getResp.User.Name, getResp.User.Email, getResp.User.Age)
		log.Printf("Roles: %v", getResp.User.Roles)
		log.Printf("Status: %s", getResp.User.Status)
		if len(getResp.User.Addresses) > 0 {
			addr := getResp.User.Addresses[0]
			log.Printf("Address: %s, %s, %s %s", addr.Street, addr.City, addr.State, addr.Zip)
		}
	} else {
		log.Printf("Failed to get user: %s", getResp.Error)
	}

	// Example 3: Try to get a non-existent user
	getReq2 := &pb.GetUserRequest{
		UserId: "nonexistent",
	}

	getResp2, err := client.GetUser(ctx, getReq2)
	if err != nil {
		log.Fatalf("could not get user: %v", err)
	}

	if !getResp2.Success {
		log.Printf("Expected error for non-existent user: %s", getResp2.Error)
	}
}

func main() {
	var (
		mode       = flag.String("mode", "both", "Run mode: 'server', 'client', or 'both'")
		serverPort = flag.String("port", ":50051", "Server port")
		serverAddr = flag.String("addr", "localhost:50051", "Server address for client mode")
	)
	flag.Parse()

	switch *mode {
	case "server":
		runServer(*serverPort)
	case "client":
		runClient(*serverAddr)
	case "both":
		// Start server in background
		go runServer(*serverPort)
		
		// Wait for server to be ready with retry loop
		maxRetries := 30 // 30 retries * 100ms = 3 seconds timeout
		connected := false
		for i := 0; i < maxRetries; i++ {
			conn, err := net.Dial("tcp", *serverAddr)
			if err == nil {
				connected = true
				conn.Close()
				break
			}
			time.Sleep(100 * time.Millisecond)
		}
		
		if !connected {
			log.Fatalf("Failed to connect to server at %s after %d retries", *serverAddr, maxRetries)
		}
		
		// Run client
		runClient(*serverAddr)
	default:
		log.Fatalf("Invalid mode: %s. Use 'server', 'client', or 'both'", *mode)
	}
}