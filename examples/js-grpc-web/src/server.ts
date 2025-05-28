import * as grpc from "@grpc/grpc-js";
import * as protoLoader from "@grpc/proto-loader";
import { v4 as uuidv4 } from "uuid";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load proto files
const PROTO_PATH = path.join(__dirname, "../proto");

const userProtoPath = path.join(PROTO_PATH, "user.proto");
const chatProtoPath = path.join(PROTO_PATH, "chat.proto");

const packageDefinition = protoLoader.loadSync([userProtoPath, chatProtoPath], {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
  includeDirs: [PROTO_PATH],
});

const protoDescriptor = grpc.loadPackageDefinition(packageDefinition);
const userProto = protoDescriptor.example.user.v1 as any;
const chatProto = protoDescriptor.example.chat.v1 as any;

// In-memory storage
const users = new Map<string, any>();
const rooms = new Map<string, any>();
const messages = new Map<string, any[]>();
const streamClients = new Map<string, grpc.ServerWritableStream<any, any>[]>();

// User Service Implementation
const userService = {
  CreateUser: (
    call: grpc.ServerUnaryCall<any, any>,
    callback: grpc.sendUnaryData<any>,
  ) => {
    const request = call.request;
    const user = {
      id: uuidv4(),
      name: request.name,
      email: request.email,
      age: request.age,
      interests: request.interests || [],
      status: "USER_STATUS_ACTIVE",
      created_at: { seconds: Math.floor(Date.now() / 1000), nanos: 0 },
      updated_at: { seconds: Math.floor(Date.now() / 1000), nanos: 0 },
    };

    users.set(user.id, user);
    console.log(`Created user: ${user.id} - ${user.name}`);

    callback(null, { user });
  },

  GetUser: (
    call: grpc.ServerUnaryCall<any, any>,
    callback: grpc.sendUnaryData<any>,
  ) => {
    const user = users.get(call.request.id);
    if (!user) {
      callback({
        code: grpc.status.NOT_FOUND,
        details: "User not found",
      });
      return;
    }
    callback(null, { user });
  },

  ListUsers: (
    call: grpc.ServerUnaryCall<any, any>,
    callback: grpc.sendUnaryData<any>,
  ) => {
    const allUsers = Array.from(users.values());
    const filteredUsers = call.request.status_filter
      ? allUsers.filter((u) => u.status === call.request.status_filter)
      : allUsers;

    const pageSize = call.request.page_size || 10;
    const users_result = filteredUsers.slice(0, pageSize);

    callback(null, {
      users: users_result,
      next_page_token: users_result.length === pageSize ? "next" : "",
      total_count: filteredUsers.length,
    });
  },

  UpdateUser: (
    call: grpc.ServerUnaryCall<any, any>,
    callback: grpc.sendUnaryData<any>,
  ) => {
    const user = users.get(call.request.id);
    if (!user) {
      callback({
        code: grpc.status.NOT_FOUND,
        details: "User not found",
      });
      return;
    }

    Object.assign(user, {
      name: call.request.name || user.name,
      email: call.request.email || user.email,
      age: call.request.age || user.age,
      interests: call.request.interests || user.interests,
      status: call.request.status || user.status,
      updated_at: { seconds: Math.floor(Date.now() / 1000), nanos: 0 },
    });

    users.set(user.id, user);
    callback(null, { user });
  },

  DeleteUser: (
    call: grpc.ServerUnaryCall<any, any>,
    callback: grpc.sendUnaryData<any>,
  ) => {
    const success = users.delete(call.request.id);
    callback(null, { success });
  },

  StreamUsers: (call: grpc.ServerWritableStream<any, any>) => {
    const statusFilter = call.request.status_filter;
    let count = 0;

    const interval = setInterval(() => {
      const allUsers = Array.from(users.values());
      const filteredUsers = statusFilter
        ? allUsers.filter((u) => u.status === statusFilter)
        : allUsers;

      if (filteredUsers.length > 0 && count < 10) {
        const user = filteredUsers[count % filteredUsers.length];
        call.write({ user });
        count++;
      } else {
        clearInterval(interval);
        call.end();
      }
    }, 1000);

    call.on("cancelled", () => {
      clearInterval(interval);
    });
  },
};

// Chat Service Implementation
const chatService = {
  SendMessage: (
    call: grpc.ServerUnaryCall<any, any>,
    callback: grpc.sendUnaryData<any>,
  ) => {
    const request = call.request;
    const message = {
      id: uuidv4(),
      user_id: request.user_id,
      room_id: request.room_id,
      content: request.content,
      sent_at: { seconds: Math.floor(Date.now() / 1000), nanos: 0 },
    };

    // Store message
    if (!messages.has(request.room_id)) {
      messages.set(request.room_id, []);
    }
    messages.get(request.room_id)!.push(message);

    // Broadcast to stream clients
    const clients = streamClients.get(request.room_id) || [];
    clients.forEach((client) => {
      try {
        client.write({ message });
      } catch (e) {
        console.error("Error writing to stream client:", e);
      }
    });

    console.log(`Message sent in room ${request.room_id}: ${request.content}`);
    callback(null, { message });
  },

  JoinRoom: (
    call: grpc.ServerUnaryCall<any, any>,
    callback: grpc.sendUnaryData<any>,
  ) => {
    const { room_id, user_id } = call.request;

    let room = rooms.get(room_id);
    if (!room) {
      room = {
        id: room_id,
        name: `Room ${room_id}`,
        participants: [],
        created_at: { seconds: Math.floor(Date.now() / 1000), nanos: 0 },
      };
      rooms.set(room_id, room);
    }

    if (!room.participants.includes(user_id)) {
      room.participants.push(user_id);
    }

    console.log(`User ${user_id} joined room ${room_id}`);
    callback(null, { room });
  },

  StreamMessages: (call: grpc.ServerWritableStream<any, any>) => {
    const { room_id, user_id } = call.request;

    // Add client to stream clients
    if (!streamClients.has(room_id)) {
      streamClients.set(room_id, []);
    }
    streamClients.get(room_id)!.push(call);

    console.log(
      `User ${user_id} started streaming messages from room ${room_id}`,
    );

    // Send existing messages
    const existingMessages = messages.get(room_id) || [];
    existingMessages.forEach((message) => {
      call.write({ message });
    });

    // Clean up on disconnect
    call.on("cancelled", () => {
      const clients = streamClients.get(room_id) || [];
      const index = clients.indexOf(call);
      if (index > -1) {
        clients.splice(index, 1);
      }
      console.log(
        `User ${user_id} stopped streaming messages from room ${room_id}`,
      );
    });
  },

  StreamChat: (call: grpc.ServerDuplexStream<any, any>) => {
    let currentRoom: string | null = null;
    let currentUser: string | null = null;

    call.on("data", (request: any) => {
      currentRoom = request.room_id;
      currentUser = request.user_id;

      const message = {
        id: uuidv4(),
        user_id: request.user_id,
        room_id: request.room_id,
        content: request.content,
        sent_at: { seconds: Math.floor(Date.now() / 1000), nanos: 0 },
      };

      // Store message
      if (!messages.has(request.room_id)) {
        messages.set(request.room_id, []);
      }
      messages.get(request.room_id)!.push(message);

      // Echo back to sender
      call.write({ message });

      // Broadcast to other clients
      const clients = streamClients.get(request.room_id) || [];
      clients.forEach((client) => {
        if (client !== call) {
          try {
            client.write({ message });
          } catch (e) {
            console.error("Error writing to stream client:", e);
          }
        }
      });
    });

    call.on("end", () => {
      call.end();
    });

    call.on("error", (err) => {
      console.error("Stream error:", err);
    });
  },
};

// Create and start the server
function main() {
  const server = new grpc.Server();

  server.addService(userProto.UserService.service, userService);
  server.addService(chatProto.ChatService.service, chatService);

  const port = "50051";
  server.bindAsync(
    `0.0.0.0:${port}`,
    grpc.ServerCredentials.createInsecure(),
    (err, port) => {
      if (err) {
        console.error("Server failed to bind:", err);
        return;
      }
      console.log(`gRPC server running on port ${port}`);
      console.log("Services available:");
      console.log("  - UserService");
      console.log("  - ChatService");
    },
  );
}

main();
