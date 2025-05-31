<?php
// GENERATED CODE -- DO NOT EDIT!

namespace Example\V1;

/**
 * Example of a more complex service
 */
class UserServiceClient extends \Grpc\BaseStub {

    /**
     * @param string $hostname hostname
     * @param array $opts channel options
     * @param \Grpc\Channel $channel (optional) re-use channel object
     */
    public function __construct($hostname, $opts, $channel = null) {
        parent::__construct($hostname, $opts, $channel);
    }

    /**
     * @param \Example\V1\GetUserRequest $argument input argument
     * @param array $metadata metadata
     * @param array $options call options
     * @return \Grpc\UnaryCall
     */
    public function GetUser(\Example\V1\GetUserRequest $argument,
      $metadata = [], $options = []) {
        return $this->_simpleRequest('/example.v1.UserService/GetUser',
        $argument,
        ['\Example\V1\GetUserResponse', 'decode'],
        $metadata, $options);
    }

    /**
     * @param \Example\V1\ListUsersRequest $argument input argument
     * @param array $metadata metadata
     * @param array $options call options
     * @return \Grpc\UnaryCall
     */
    public function ListUsers(\Example\V1\ListUsersRequest $argument,
      $metadata = [], $options = []) {
        return $this->_simpleRequest('/example.v1.UserService/ListUsers',
        $argument,
        ['\Example\V1\ListUsersResponse', 'decode'],
        $metadata, $options);
    }

    /**
     * @param \Example\V1\CreateUserRequest $argument input argument
     * @param array $metadata metadata
     * @param array $options call options
     * @return \Grpc\UnaryCall
     */
    public function CreateUser(\Example\V1\CreateUserRequest $argument,
      $metadata = [], $options = []) {
        return $this->_simpleRequest('/example.v1.UserService/CreateUser',
        $argument,
        ['\Example\V1\CreateUserResponse', 'decode'],
        $metadata, $options);
    }

    /**
     * @param \Example\V1\UpdateUserRequest $argument input argument
     * @param array $metadata metadata
     * @param array $options call options
     * @return \Grpc\UnaryCall
     */
    public function UpdateUser(\Example\V1\UpdateUserRequest $argument,
      $metadata = [], $options = []) {
        return $this->_simpleRequest('/example.v1.UserService/UpdateUser',
        $argument,
        ['\Example\V1\UpdateUserResponse', 'decode'],
        $metadata, $options);
    }

    /**
     * @param \Example\V1\DeleteUserRequest $argument input argument
     * @param array $metadata metadata
     * @param array $options call options
     * @return \Grpc\UnaryCall
     */
    public function DeleteUser(\Example\V1\DeleteUserRequest $argument,
      $metadata = [], $options = []) {
        return $this->_simpleRequest('/example.v1.UserService/DeleteUser',
        $argument,
        ['\Example\V1\DeleteUserResponse', 'decode'],
        $metadata, $options);
    }

}
