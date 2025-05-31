import { create } from "@bufbuild/protobuf";
import { UserServiceClient } from "../proto/gen/js/user_grpc_web_pb.js";
import { ChatServiceClient } from "../proto/gen/js/chat_grpc_web_pb.js";
import {
  CreateUserRequest,
  CreateUserRequestSchema,
  GetUserRequest,
  GetUserRequestSchema,
  ListUsersRequest,
  ListUsersRequestSchema,
  UpdateUserRequest,
  UpdateUserRequestSchema,
  DeleteUserRequest,
  DeleteUserRequestSchema,
  StreamUsersRequest,
  StreamUsersRequestSchema,
  UserStatus,
} from "../proto/gen/js/user_pb.js";
import {
  SendMessageRequest,
  SendMessageRequestSchema,
  JoinRoomRequest,
  JoinRoomRequestSchema,
  StreamMessagesRequest,
  StreamMessagesRequestSchema,
} from "../proto/gen/js/chat_pb.js";

// Configure the gRPC-Web client to connect through Envoy proxy
const GRPC_WEB_URL = "http://localhost:8080";

const userClient = new UserServiceClient(GRPC_WEB_URL);
const chatClient = new ChatServiceClient(GRPC_WEB_URL);

// Helper function to handle errors
function handleError(methodName: string, error: any) {
  console.error(`Error in ${methodName}:`, error.message || error);
}

// User Service Examples
async function userServiceExamples() {
  console.log("\n=== User Service Examples ===\n");

  // 1. Create a user
  console.log("1. Creating a user...");
  const createUserRequest = create(CreateUserRequestSchema, {
    name: "Alice Smith",
    email: "alice@example.com",
    age: 28,
    interests: ["coding", "reading", "hiking"],
  });

  try {
    const createResponse = await new Promise((resolve, reject) => {
      userClient.createUser(createUserRequest, {}, (err, response) => {
        if (err) reject(err);
        else resolve(response);
      });
    });

    const createdUser = (createResponse as any).getUser();
    const userId = createdUser.getId();
    console.log(`Created user with ID: ${userId}`);
    console.log(`  Name: ${createdUser.getName()}`);
    console.log(`  Email: ${createdUser.getEmail()}`);
    console.log(`  Interests: ${createdUser.getInterestsList().join(", ")}`);

    // 2. Get the user
    console.log("\n2. Getting user by ID...");
    const getUserRequest = create(GetUserRequestSchema, {
      id: userId,
    });

    const getResponse = await new Promise((resolve, reject) => {
      userClient.getUser(getUserRequest, {}, (err, response) => {
        if (err) reject(err);
        else resolve(response);
      });
    });

    const fetchedUser = (getResponse as any).getUser();
    console.log(
      `Fetched user: ${fetchedUser.getName()} (${fetchedUser.getEmail()})`,
    );

    // 3. Update the user
    console.log("\n3. Updating user...");
    const updateUserRequest = create(UpdateUserRequestSchema, {
      id: userId,
      name: "Alice Johnson",
      age: 29,
      status: UserStatus.ACTIVE,
    });

    const updateResponse = await new Promise((resolve, reject) => {
      userClient.updateUser(updateUserRequest, {}, (err, response) => {
        if (err) reject(err);
        else resolve(response);
      });
    });

    const updatedUser = (updateResponse as any).getUser();
    console.log(
      `Updated user: ${updatedUser.getName()} (age: ${updatedUser.getAge()})`,
    );

    // 4. List users
    console.log("\n4. Listing users...");
    const listUsersRequest = create(ListUsersRequestSchema, {
      pageSize: 10,
    });

    const listResponse = await new Promise((resolve, reject) => {
      userClient.listUsers(listUsersRequest, {}, (err, response) => {
        if (err) reject(err);
        else resolve(response);
      });
    });

    const usersList = (listResponse as any).getUsersList();
    console.log(`Found ${usersList.length} users:`);
    usersList.forEach((user: any) => {
      console.log(`  - ${user.getName()} (${user.getEmail()})`);
    });

    // 5. Stream users (server streaming)
    console.log("\n5. Streaming users...");
    const streamUsersRequest = create(StreamUsersRequestSchema, {
      statusFilter: UserStatus.ACTIVE,
    });

    const stream = userClient.streamUsers(streamUsersRequest, {});
    let streamCount = 0;

    stream.on("data", (response: any) => {
      streamCount++;
      const user = response.getUser();
      console.log(
        `  Stream ${streamCount}: ${user.getName()} (${user.getEmail()})`,
      );
    });

    stream.on("error", (err: any) => {
      if (err.code !== 1) {
        // Ignore CANCELLED errors
        handleError("streamUsers", err);
      }
    });

    stream.on("end", () => {
      console.log("  Stream ended");
    });

    // Wait a bit for streaming to complete
    await new Promise((resolve) => setTimeout(resolve, 2000));

    // 6. Delete the user
    console.log("\n6. Deleting user...");
    const deleteUserRequest = create(DeleteUserRequestSchema, {
      id: userId,
    });

    const deleteResponse = await new Promise((resolve, reject) => {
      userClient.deleteUser(deleteUserRequest, {}, (err, response) => {
        if (err) reject(err);
        else resolve(response);
      });
    });

    console.log(`User deleted: ${(deleteResponse as any).getSuccess()}`);
  } catch (error) {
    handleError("userServiceExamples", error);
  }
}

// Chat Service Examples
async function chatServiceExamples() {
  console.log("\n\n=== Chat Service Examples ===\n");

  const roomId = "room-123";
  const userId1 = "user-1";
  const userId2 = "user-2";

  try {
    // 1. Join a room
    console.log("1. Joining chat room...");
    const joinRoomRequest = create(JoinRoomRequestSchema, {
      roomId: roomId,
      userId: userId1,
    });

    const joinResponse = await new Promise((resolve, reject) => {
      chatClient.joinRoom(joinRoomRequest, {}, (err, response) => {
        if (err) reject(err);
        else resolve(response);
      });
    });

    const room = (joinResponse as any).getRoom();
    console.log(`Joined room: ${room.getName()} (ID: ${room.getId()})`);
    console.log(`Participants: ${room.getParticipantsList().join(", ")}`);

    // 2. Send messages
    console.log("\n2. Sending messages...");
    const messages = [
      "Hello everyone!",
      "How is everyone doing today?",
      "This is a test of gRPC-Web chat!",
    ];

    for (const content of messages) {
      const sendMessageRequest = create(SendMessageRequestSchema, {
        roomId: roomId,
        userId: userId1,
        content: content,
      });

      const messageResponse = await new Promise((resolve, reject) => {
        chatClient.sendMessage(sendMessageRequest, {}, (err, response) => {
          if (err) reject(err);
          else resolve(response);
        });
      });

      const message = (messageResponse as any).getMessage();
      console.log(`  Sent: "${message.getContent()}" (ID: ${message.getId()})`);

      // Small delay between messages
      await new Promise((resolve) => setTimeout(resolve, 500));
    }

    // 3. Stream messages
    console.log("\n3. Streaming messages from room...");
    const streamMessagesRequest = create(StreamMessagesRequestSchema, {
      roomId: roomId,
      userId: userId2,
    });

    const messageStream = chatClient.streamMessages(streamMessagesRequest, {});
    let messageCount = 0;

    messageStream.on("data", (response: any) => {
      messageCount++;
      const message = response.getMessage();
      console.log(
        `  Message ${messageCount}: "${message.getContent()}" from ${message.getUserId()}`,
      );
    });

    messageStream.on("error", (err: any) => {
      if (err.code !== 1) {
        // Ignore CANCELLED errors
        handleError("streamMessages", err);
      }
    });

    messageStream.on("end", () => {
      console.log("  Message stream ended");
    });

    // Send another message to see it in the stream
    await new Promise((resolve) => setTimeout(resolve, 1000));

    const liveMessageRequest = create(SendMessageRequestSchema, {
      roomId: roomId,
      userId: userId2,
      content: "This message should appear in the stream!",
    });

    await new Promise((resolve, reject) => {
      chatClient.sendMessage(liveMessageRequest, {}, (err, response) => {
        if (err) reject(err);
        else resolve(response);
      });
    });

    // Wait for streaming
    await new Promise((resolve) => setTimeout(resolve, 2000));
  } catch (error) {
    handleError("chatServiceExamples", error);
  }
}

// Main function
async function main() {
  console.log("gRPC-Web Client Example");
  console.log("=======================");
  console.log(`Connecting to gRPC-Web server at ${GRPC_WEB_URL}`);

  try {
    await userServiceExamples();
    await chatServiceExamples();
  } catch (error) {
    console.error("Fatal error:", error);
  }

  console.log("\n\nAll examples completed!");
}

// Run the examples
main().catch(console.error);
