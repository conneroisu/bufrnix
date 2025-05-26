//
//  Generated code. Do not modify.
//  source: example/v1/example.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'example.pb.dart' as $0;

export 'example.pb.dart';

@$pb.GrpcServiceName('example.v1.ExampleService')
class ExampleServiceClient extends $grpc.Client {
  static final _$createExample = $grpc.ClientMethod<$0.CreateExampleRequest, $0.CreateExampleResponse>(
      '/example.v1.ExampleService/CreateExample',
      ($0.CreateExampleRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.CreateExampleResponse.fromBuffer(value));
  static final _$getExample = $grpc.ClientMethod<$0.GetExampleRequest, $0.GetExampleResponse>(
      '/example.v1.ExampleService/GetExample',
      ($0.GetExampleRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetExampleResponse.fromBuffer(value));
  static final _$listExamples = $grpc.ClientMethod<$0.ListExamplesRequest, $0.ListExamplesResponse>(
      '/example.v1.ExampleService/ListExamples',
      ($0.ListExamplesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListExamplesResponse.fromBuffer(value));
  static final _$deleteExample = $grpc.ClientMethod<$0.DeleteExampleRequest, $0.DeleteExampleResponse>(
      '/example.v1.ExampleService/DeleteExample',
      ($0.DeleteExampleRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.DeleteExampleResponse.fromBuffer(value));
  static final _$watchExamples = $grpc.ClientMethod<$0.ListExamplesRequest, $0.ExampleMessage>(
      '/example.v1.ExampleService/WatchExamples',
      ($0.ListExamplesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ExampleMessage.fromBuffer(value));

  ExampleServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.CreateExampleResponse> createExample($0.CreateExampleRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createExample, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetExampleResponse> getExample($0.GetExampleRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getExample, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListExamplesResponse> listExamples($0.ListExamplesRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listExamples, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteExampleResponse> deleteExample($0.DeleteExampleRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$deleteExample, request, options: options);
  }

  $grpc.ResponseStream<$0.ExampleMessage> watchExamples($0.ListExamplesRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$watchExamples, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('example.v1.ExampleService')
abstract class ExampleServiceBase extends $grpc.Service {
  $core.String get $name => 'example.v1.ExampleService';

  ExampleServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateExampleRequest, $0.CreateExampleResponse>(
        'CreateExample',
        createExample_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateExampleRequest.fromBuffer(value),
        ($0.CreateExampleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetExampleRequest, $0.GetExampleResponse>(
        'GetExample',
        getExample_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetExampleRequest.fromBuffer(value),
        ($0.GetExampleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListExamplesRequest, $0.ListExamplesResponse>(
        'ListExamples',
        listExamples_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListExamplesRequest.fromBuffer(value),
        ($0.ListExamplesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteExampleRequest, $0.DeleteExampleResponse>(
        'DeleteExample',
        deleteExample_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteExampleRequest.fromBuffer(value),
        ($0.DeleteExampleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListExamplesRequest, $0.ExampleMessage>(
        'WatchExamples',
        watchExamples_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.ListExamplesRequest.fromBuffer(value),
        ($0.ExampleMessage value) => value.writeToBuffer()));
  }

  $async.Future<$0.CreateExampleResponse> createExample_Pre($grpc.ServiceCall call, $async.Future<$0.CreateExampleRequest> request) async {
    return createExample(call, await request);
  }

  $async.Future<$0.GetExampleResponse> getExample_Pre($grpc.ServiceCall call, $async.Future<$0.GetExampleRequest> request) async {
    return getExample(call, await request);
  }

  $async.Future<$0.ListExamplesResponse> listExamples_Pre($grpc.ServiceCall call, $async.Future<$0.ListExamplesRequest> request) async {
    return listExamples(call, await request);
  }

  $async.Future<$0.DeleteExampleResponse> deleteExample_Pre($grpc.ServiceCall call, $async.Future<$0.DeleteExampleRequest> request) async {
    return deleteExample(call, await request);
  }

  $async.Stream<$0.ExampleMessage> watchExamples_Pre($grpc.ServiceCall call, $async.Future<$0.ListExamplesRequest> request) async* {
    yield* watchExamples(call, await request);
  }

  $async.Future<$0.CreateExampleResponse> createExample($grpc.ServiceCall call, $0.CreateExampleRequest request);
  $async.Future<$0.GetExampleResponse> getExample($grpc.ServiceCall call, $0.GetExampleRequest request);
  $async.Future<$0.ListExamplesResponse> listExamples($grpc.ServiceCall call, $0.ListExamplesRequest request);
  $async.Future<$0.DeleteExampleResponse> deleteExample($grpc.ServiceCall call, $0.DeleteExampleRequest request);
  $async.Stream<$0.ExampleMessage> watchExamples($grpc.ServiceCall call, $0.ListExamplesRequest request);
}
