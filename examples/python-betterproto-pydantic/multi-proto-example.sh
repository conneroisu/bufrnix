#!/usr/bin/env bash
set -euo pipefail

echo "Multi-Proto File Example for Bufrnix"
echo "===================================="
echo ""
echo "This demonstrates how bufrnix handles multiple proto files"
echo ""

# Example of creating multiple proto files for testing
mkdir -p proto/services proto/models

# Create a models proto file
cat > proto/models/user.proto << 'EOF'
syntax = "proto3";

package models;

message User {
  int32 id = 1;
  string name = 2;
  string email = 3;
}

message UserList {
  repeated User users = 1;
}
EOF

# Create a service proto file that imports the models
cat > proto/services/user_service.proto << 'EOF'
syntax = "proto3";

package services;

import "models/user.proto";

service UserService {
  rpc GetUser(GetUserRequest) returns (models.User);
  rpc ListUsers(ListUsersRequest) returns (models.UserList);
}

message GetUserRequest {
  int32 user_id = 1;
}

message ListUsersRequest {
  int32 limit = 1;
  int32 offset = 2;
}
EOF

echo "Created example proto files:"
echo ""

# Show all proto files that bufrnix will discover
proto_files=$(find "proto" -type f -name "*.proto" | sort)
for file in $proto_files; do
    echo "  - $file"
done

echo ""
echo "Note: Bufrnix will automatically discover and process all these files"
echo "      when you run 'bufrnix' command. The 'find' command above mimics"
echo "      how bufrnix discovers proto files internally."
echo ""
echo "To test: Run './test.sh' which will process all proto files"

# Clean up the example files
rm -rf proto/services proto/models