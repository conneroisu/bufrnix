package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	// Generated protobuf packages - ONLY backend services
	commonv1 "github.com/example/backend/generated/go/common/v1"
	internalv1 "github.com/example/backend/generated/go/internal/v1"
)

// UserServiceServer implements the internal UserService
type UserServiceServer struct {
	internalv1.UnimplementedUserServiceServer
	users map[string]*commonv1.User
}

func (s *UserServiceServer) CreateUser(ctx context.Context, req *internalv1.CreateUserRequest) (*internalv1.CreateUserResponse, error) {
	log.Printf("Creating user: %s (%s)", req.Name, req.Email)

	user := &commonv1.User{
		Id:        fmt.Sprintf("user_%d", time.Now().Unix()),
		Email:     req.Email,
		Name:      req.Name,
		Status:    req.InitialStatus,
		CreatedAt: time.Now().Unix(),
		UpdatedAt: time.Now().Unix(),
	}

	s.users[user.Id] = user

	return &internalv1.CreateUserResponse{
		Status: commonv1.ResponseStatus_RESPONSE_STATUS_SUCCESS,
		User:   user,
	}, nil
}

func (s *UserServiceServer) GetUserByInternalId(ctx context.Context, req *internalv1.GetUserByInternalIdRequest) (*internalv1.GetUserByInternalIdResponse, error) {
	log.Printf("Getting user by internal ID: %d", req.InternalId)

	// In a real implementation, you'd look up by internal ID
	// For demo purposes, just return a sample user
	for _, user := range s.users {
		return &internalv1.GetUserByInternalIdResponse{
			User: user,
			Metadata: &internalv1.InternalUserMetadata{
				InternalId:     req.InternalId,
				PasswordHash:   "[REDACTED]",
				Salt:          "[REDACTED]",
				Roles:         []string{"user", "beta_tester"},
				Permissions:   []string{"read:profile", "write:profile"},
				LastLoginAt:   time.Now().Add(-2 * time.Hour).Unix(),
				LastLoginIp:   "192.168.1.100",
				LoginAttempts: 0,
				IsLocked:      false,
			},
		}, nil
	}

	return nil, status.Error(codes.NotFound, "User not found")
}

func (s *UserServiceServer) HealthCheck(ctx context.Context, req *internalv1.HealthCheckRequest) (*internalv1.HealthCheckResponse, error) {
	return &internalv1.HealthCheckResponse{
		Health: &commonv1.HealthCheck{
			Status:    commonv1.ResponseStatus_RESPONSE_STATUS_SUCCESS,
			Version:   "1.0.0",
			Timestamp: time.Now().Unix(),
			Metadata: map[string]string{
				"service":     req.ServiceName,
				"environment": "development",
				"region":      "local",
			},
		},
		Metrics: &internalv1.ServiceMetrics{
			UptimeSeconds:     3600,
			TotalRequests:     1234,
			ActiveConnections: 5,
			CpuUsage:          0.15,
			MemoryUsage:       0.45,
		},
	}, nil
}

// AdminServiceServer implements the internal AdminService
type AdminServiceServer struct {
	internalv1.UnimplementedAdminServiceServer
	userService *UserServiceServer
}

func (s *AdminServiceServer) GetSystemStats(ctx context.Context, req *internalv1.GetSystemStatsRequest) (*internalv1.GetSystemStatsResponse, error) {
	log.Printf("Getting system stats (detailed: %v)", req.IncludeDetailedMetrics)

	return &internalv1.GetSystemStatsResponse{
		Stats: &internalv1.SystemStats{
			TotalUsers:           int64(len(s.userService.users)),
			ActiveUsers:          int64(len(s.userService.users)),
			SuspendedUsers:       0,
			TotalRequestsToday:   5000,
			AvgResponseTimeMs:    25.5,
			CacheHitRate:         85,
			DatabaseConnections:  10,
			Services: []*internalv1.ServiceHealth{
				{
					Name:           "user-service",
					Status:         commonv1.ResponseStatus_RESPONSE_STATUS_SUCCESS,
					Version:        "1.0.0",
					UptimeSeconds:  3600,
				},
				{
					Name:           "admin-service", 
					Status:         commonv1.ResponseStatus_RESPONSE_STATUS_SUCCESS,
					Version:        "1.0.0",
					UptimeSeconds:  3600,
				},
			},
		},
	}, nil
}

func main() {
	fmt.Println("🐹 Go Backend Server - Internal Services Only")
	fmt.Println("=============================================")
	fmt.Println("")
	fmt.Println("✅ Generated protobuf packages:")
	fmt.Println("  • common/v1     - Shared types")
	fmt.Println("  • internal/v1   - Internal gRPC services")
	fmt.Println("")
	fmt.Println("❌ NOT generated (correctly excluded):")
	fmt.Println("  • api/v1        - Public REST APIs (JS only)")
	fmt.Println("  • google/api/*  - Google annotations (prevents linting errors)")
	fmt.Println("")

	// Create services
	userService := &UserServiceServer{
		users: make(map[string]*commonv1.User),
	}
	adminService := &AdminServiceServer{
		userService: userService,
	}

	// Create some sample users
	userService.CreateUser(context.Background(), &internalv1.CreateUserRequest{
		Email:         "alice@example.com",
		Name:          "Alice Johnson",
		HashedPassword: "[HASHED]",
		InitialStatus: commonv1.UserStatus_USER_STATUS_ACTIVE,
		Metadata: map[string]string{
			"source":      "demo",
			"signup_date": time.Now().Format(time.RFC3339),
		},
	})

	// Set up gRPC server
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	s := grpc.NewServer()
	internalv1.RegisterUserServiceServer(s, userService)
	internalv1.RegisterAdminServiceServer(s, adminService)

	fmt.Println("🚀 gRPC server starting on :50051...")
	fmt.Println("   - UserService: Internal user operations")
	fmt.Println("   - AdminService: System administration")
	fmt.Println("")
	fmt.Println("💡 This demonstrates Go backend with smart file exclusions:")
	fmt.Println("   - Processes internal services only")
	fmt.Println("   - No Google API annotations (prevents Go linting errors)")
	fmt.Println("   - No public APIs (frontend responsibility)")
	fmt.Println("")

	if err := s.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}