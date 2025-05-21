//
//  Generated code. Do not modify.
//  source: example/v1/example.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use exampleMessageDescriptor instead')
const ExampleMessage$json = {
  '1': 'ExampleMessage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'tags', '3': 4, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'description', '17': true},
    {'1': 'created_at', '3': 6, '4': 1, '5': 11, '6': '.example.v1.TimestampMessage', '10': 'createdAt'},
  ],
  '8': [
    {'1': '_description'},
  ],
};

/// Descriptor for `ExampleMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exampleMessageDescriptor = $convert.base64Decode(
    'Cg5FeGFtcGxlTWVzc2FnZRIOCgJpZBgBIAEoBVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIUCg'
    'VlbWFpbBgDIAEoCVIFZW1haWwSEgoEdGFncxgEIAMoCVIEdGFncxIlCgtkZXNjcmlwdGlvbhgF'
    'IAEoCUgAUgtkZXNjcmlwdGlvbogBARI7CgpjcmVhdGVkX2F0GAYgASgLMhwuZXhhbXBsZS52MS'
    '5UaW1lc3RhbXBNZXNzYWdlUgljcmVhdGVkQXRCDgoMX2Rlc2NyaXB0aW9u');

@$core.Deprecated('Use timestampMessageDescriptor instead')
const TimestampMessage$json = {
  '1': 'TimestampMessage',
  '2': [
    {'1': 'seconds', '3': 1, '4': 1, '5': 3, '10': 'seconds'},
    {'1': 'nanos', '3': 2, '4': 1, '5': 5, '10': 'nanos'},
  ],
};

/// Descriptor for `TimestampMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timestampMessageDescriptor = $convert.base64Decode(
    'ChBUaW1lc3RhbXBNZXNzYWdlEhgKB3NlY29uZHMYASABKANSB3NlY29uZHMSFAoFbmFub3MYAi'
    'ABKAVSBW5hbm9z');

@$core.Deprecated('Use createExampleRequestDescriptor instead')
const CreateExampleRequest$json = {
  '1': 'CreateExampleRequest',
  '2': [
    {'1': 'example', '3': 1, '4': 1, '5': 11, '6': '.example.v1.ExampleMessage', '10': 'example'},
  ],
};

/// Descriptor for `CreateExampleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createExampleRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVFeGFtcGxlUmVxdWVzdBI0CgdleGFtcGxlGAEgASgLMhouZXhhbXBsZS52MS5FeG'
    'FtcGxlTWVzc2FnZVIHZXhhbXBsZQ==');

@$core.Deprecated('Use createExampleResponseDescriptor instead')
const CreateExampleResponse$json = {
  '1': 'CreateExampleResponse',
  '2': [
    {'1': 'example', '3': 1, '4': 1, '5': 11, '6': '.example.v1.ExampleMessage', '10': 'example'},
    {'1': 'success', '3': 2, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `CreateExampleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createExampleResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVFeGFtcGxlUmVzcG9uc2USNAoHZXhhbXBsZRgBIAEoCzIaLmV4YW1wbGUudjEuRX'
    'hhbXBsZU1lc3NhZ2VSB2V4YW1wbGUSGAoHc3VjY2VzcxgCIAEoCFIHc3VjY2VzcxIYCgdtZXNz'
    'YWdlGAMgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use getExampleRequestDescriptor instead')
const GetExampleRequest$json = {
  '1': 'GetExampleRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
  ],
};

/// Descriptor for `GetExampleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getExampleRequestDescriptor = $convert.base64Decode(
    'ChFHZXRFeGFtcGxlUmVxdWVzdBIOCgJpZBgBIAEoBVICaWQ=');

@$core.Deprecated('Use getExampleResponseDescriptor instead')
const GetExampleResponse$json = {
  '1': 'GetExampleResponse',
  '2': [
    {'1': 'example', '3': 1, '4': 1, '5': 11, '6': '.example.v1.ExampleMessage', '10': 'example'},
    {'1': 'found', '3': 2, '4': 1, '5': 8, '10': 'found'},
  ],
};

/// Descriptor for `GetExampleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getExampleResponseDescriptor = $convert.base64Decode(
    'ChJHZXRFeGFtcGxlUmVzcG9uc2USNAoHZXhhbXBsZRgBIAEoCzIaLmV4YW1wbGUudjEuRXhhbX'
    'BsZU1lc3NhZ2VSB2V4YW1wbGUSFAoFZm91bmQYAiABKAhSBWZvdW5k');

@$core.Deprecated('Use listExamplesRequestDescriptor instead')
const ListExamplesRequest$json = {
  '1': 'ListExamplesRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'filter', '3': 3, '4': 1, '5': 9, '10': 'filter'},
  ],
};

/// Descriptor for `ListExamplesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listExamplesRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0RXhhbXBsZXNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZVNpemUSHQoKcG'
    'FnZV90b2tlbhgCIAEoCVIJcGFnZVRva2VuEhYKBmZpbHRlchgDIAEoCVIGZmlsdGVy');

@$core.Deprecated('Use listExamplesResponseDescriptor instead')
const ListExamplesResponse$json = {
  '1': 'ListExamplesResponse',
  '2': [
    {'1': 'examples', '3': 1, '4': 3, '5': 11, '6': '.example.v1.ExampleMessage', '10': 'examples'},
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListExamplesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listExamplesResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0RXhhbXBsZXNSZXNwb25zZRI2CghleGFtcGxlcxgBIAMoCzIaLmV4YW1wbGUudjEuRX'
    'hhbXBsZU1lc3NhZ2VSCGV4YW1wbGVzEiYKD25leHRfcGFnZV90b2tlbhgCIAEoCVINbmV4dFBh'
    'Z2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use deleteExampleRequestDescriptor instead')
const DeleteExampleRequest$json = {
  '1': 'DeleteExampleRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
  ],
};

/// Descriptor for `DeleteExampleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteExampleRequestDescriptor = $convert.base64Decode(
    'ChREZWxldGVFeGFtcGxlUmVxdWVzdBIOCgJpZBgBIAEoBVICaWQ=');

@$core.Deprecated('Use deleteExampleResponseDescriptor instead')
const DeleteExampleResponse$json = {
  '1': 'DeleteExampleResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DeleteExampleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteExampleResponseDescriptor = $convert.base64Decode(
    'ChVEZWxldGVFeGFtcGxlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZX'
    'NzYWdlGAIgASgJUgdtZXNzYWdl');

