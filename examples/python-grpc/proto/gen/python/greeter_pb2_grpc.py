# Generated by the gRPC Python protocol compiler plugin. DO NOT EDIT!
"""Client and server classes corresponding to protobuf-defined services."""
import grpc

import greeter_pb2 as greeter__pb2


class GreeterStub(object):
    """Missing associated documentation comment in .proto file."""

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.SayHello = channel.unary_unary(
                '/greeter.Greeter/SayHello',
                request_serializer=greeter__pb2.HelloRequest.SerializeToString,
                response_deserializer=greeter__pb2.HelloReply.FromString,
                _registered_method=True)
        self.SayHelloStream = channel.unary_stream(
                '/greeter.Greeter/SayHelloStream',
                request_serializer=greeter__pb2.HelloRequest.SerializeToString,
                response_deserializer=greeter__pb2.HelloReply.FromString,
                _registered_method=True)


class GreeterServicer(object):
    """Missing associated documentation comment in .proto file."""

    def SayHello(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def SayHelloStream(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_GreeterServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'SayHello': grpc.unary_unary_rpc_method_handler(
                    servicer.SayHello,
                    request_deserializer=greeter__pb2.HelloRequest.FromString,
                    response_serializer=greeter__pb2.HelloReply.SerializeToString,
            ),
            'SayHelloStream': grpc.unary_stream_rpc_method_handler(
                    servicer.SayHelloStream,
                    request_deserializer=greeter__pb2.HelloRequest.FromString,
                    response_serializer=greeter__pb2.HelloReply.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'greeter.Greeter', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))
    server.add_registered_method_handlers('greeter.Greeter', rpc_method_handlers)


 # This class is part of an EXPERIMENTAL API.
class Greeter(object):
    """Missing associated documentation comment in .proto file."""

    @staticmethod
    def SayHello(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(
            request,
            target,
            '/greeter.Greeter/SayHello',
            greeter__pb2.HelloRequest.SerializeToString,
            greeter__pb2.HelloReply.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)

    @staticmethod
    def SayHelloStream(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_stream(
            request,
            target,
            '/greeter.Greeter/SayHelloStream',
            greeter__pb2.HelloRequest.SerializeToString,
            greeter__pb2.HelloReply.FromString,
            options,
            channel_credentials,
            insecure,
            call_credentials,
            compression,
            wait_for_ready,
            timeout,
            metadata,
            _registered_method=True)
