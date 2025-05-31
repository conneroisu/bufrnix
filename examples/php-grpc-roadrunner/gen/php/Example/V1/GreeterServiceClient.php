<?php
// GENERATED CODE -- DO NOT EDIT!

namespace Example\V1;

/**
 * The greeting service definition
 */
class GreeterServiceClient extends \Grpc\BaseStub {

    /**
     * @param string $hostname hostname
     * @param array $opts channel options
     * @param \Grpc\Channel $channel (optional) re-use channel object
     */
    public function __construct($hostname, $opts, $channel = null) {
        parent::__construct($hostname, $opts, $channel);
    }

    /**
     * Simple unary RPC
     * @param \Example\V1\HelloRequest $argument input argument
     * @param array $metadata metadata
     * @param array $options call options
     * @return \Grpc\UnaryCall
     */
    public function SayHello(\Example\V1\HelloRequest $argument,
      $metadata = [], $options = []) {
        return $this->_simpleRequest('/example.v1.GreeterService/SayHello',
        $argument,
        ['\Example\V1\HelloResponse', 'decode'],
        $metadata, $options);
    }

    /**
     * Server streaming RPC
     * @param \Example\V1\HelloRequest $argument input argument
     * @param array $metadata metadata
     * @param array $options call options
     * @return \Grpc\ServerStreamingCall
     */
    public function SayHelloStream(\Example\V1\HelloRequest $argument,
      $metadata = [], $options = []) {
        return $this->_serverStreamRequest('/example.v1.GreeterService/SayHelloStream',
        $argument,
        ['\Example\V1\HelloResponse', 'decode'],
        $metadata, $options);
    }

    /**
     * Client streaming RPC
     * @param array $metadata metadata
     * @param array $options call options
     * @return \Grpc\ClientStreamingCall
     */
    public function SayHelloClientStream($metadata = [], $options = []) {
        return $this->_clientStreamRequest('/example.v1.GreeterService/SayHelloClientStream',
        ['\Example\V1\HelloResponse','decode'],
        $metadata, $options);
    }

    /**
     * Bidirectional streaming RPC
     * @param array $metadata metadata
     * @param array $options call options
     * @return \Grpc\BidiStreamingCall
     */
    public function SayHelloBidirectional($metadata = [], $options = []) {
        return $this->_bidiRequest('/example.v1.GreeterService/SayHelloBidirectional',
        ['\Example\V1\HelloResponse','decode'],
        $metadata, $options);
    }

}
