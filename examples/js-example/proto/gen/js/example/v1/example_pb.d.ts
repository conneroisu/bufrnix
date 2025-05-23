// @generated by protoc-gen-es v2.2.5
// @generated from file example/v1/example.proto (package example.v1, syntax proto3)
/* eslint-disable */

import type {
  GenFile,
  GenMessage,
  GenService,
} from "@bufbuild/protobuf/codegenv1";
import type { Message } from "@bufbuild/protobuf";

/**
 * Describes the file example/v1/example.proto.
 */
export declare const file_example_v1_example: GenFile;

/**
 * Example message
 *
 * @generated from message example.v1.User
 */
export declare type User = Message<"example.v1.User"> & {
  /**
   * @generated from field: string id = 1;
   */
  id: string;

  /**
   * @generated from field: string name = 2;
   */
  name: string;

  /**
   * @generated from field: string email = 3;
   */
  email: string;

  /**
   * @generated from field: int32 age = 4;
   */
  age: number;
};

/**
 * Describes the message example.v1.User.
 * Use `create(UserSchema)` to create a new message.
 */
export declare const UserSchema: GenMessage<User>;

/**
 * @generated from message example.v1.GetUserRequest
 */
export declare type GetUserRequest = Message<"example.v1.GetUserRequest"> & {
  /**
   * @generated from field: string id = 1;
   */
  id: string;
};

/**
 * Describes the message example.v1.GetUserRequest.
 * Use `create(GetUserRequestSchema)` to create a new message.
 */
export declare const GetUserRequestSchema: GenMessage<GetUserRequest>;

/**
 * @generated from message example.v1.GetUserResponse
 */
export declare type GetUserResponse = Message<"example.v1.GetUserResponse"> & {
  /**
   * @generated from field: example.v1.User user = 1;
   */
  user?: User;
};

/**
 * Describes the message example.v1.GetUserResponse.
 * Use `create(GetUserResponseSchema)` to create a new message.
 */
export declare const GetUserResponseSchema: GenMessage<GetUserResponse>;

/**
 * @generated from message example.v1.ListUsersRequest
 */
export declare type ListUsersRequest =
  Message<"example.v1.ListUsersRequest"> & {
    /**
     * @generated from field: int32 page_size = 1;
     */
    pageSize: number;

    /**
     * @generated from field: string page_token = 2;
     */
    pageToken: string;
  };

/**
 * Describes the message example.v1.ListUsersRequest.
 * Use `create(ListUsersRequestSchema)` to create a new message.
 */
export declare const ListUsersRequestSchema: GenMessage<ListUsersRequest>;

/**
 * @generated from message example.v1.ListUsersResponse
 */
export declare type ListUsersResponse =
  Message<"example.v1.ListUsersResponse"> & {
    /**
     * @generated from field: repeated example.v1.User users = 1;
     */
    users: User[];

    /**
     * @generated from field: string next_page_token = 2;
     */
    nextPageToken: string;
  };

/**
 * Describes the message example.v1.ListUsersResponse.
 * Use `create(ListUsersResponseSchema)` to create a new message.
 */
export declare const ListUsersResponseSchema: GenMessage<ListUsersResponse>;

/**
 * @generated from message example.v1.CreateUserRequest
 */
export declare type CreateUserRequest =
  Message<"example.v1.CreateUserRequest"> & {
    /**
     * @generated from field: example.v1.User user = 1;
     */
    user?: User;
  };

/**
 * Describes the message example.v1.CreateUserRequest.
 * Use `create(CreateUserRequestSchema)` to create a new message.
 */
export declare const CreateUserRequestSchema: GenMessage<CreateUserRequest>;

/**
 * @generated from message example.v1.CreateUserResponse
 */
export declare type CreateUserResponse =
  Message<"example.v1.CreateUserResponse"> & {
    /**
     * @generated from field: example.v1.User user = 1;
     */
    user?: User;
  };

/**
 * Describes the message example.v1.CreateUserResponse.
 * Use `create(CreateUserResponseSchema)` to create a new message.
 */
export declare const CreateUserResponseSchema: GenMessage<CreateUserResponse>;

/**
 * Example service
 *
 * @generated from service example.v1.UserService
 */
export declare const UserService: GenService<{
  /**
   * @generated from rpc example.v1.UserService.GetUser
   */
  getUser: {
    methodKind: "unary";
    input: typeof GetUserRequestSchema;
    output: typeof GetUserResponseSchema;
  };
  /**
   * @generated from rpc example.v1.UserService.ListUsers
   */
  listUsers: {
    methodKind: "unary";
    input: typeof ListUsersRequestSchema;
    output: typeof ListUsersResponseSchema;
  };
  /**
   * @generated from rpc example.v1.UserService.CreateUser
   */
  createUser: {
    methodKind: "unary";
    input: typeof CreateUserRequestSchema;
    output: typeof CreateUserResponseSchema;
  };
}>;
