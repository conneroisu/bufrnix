# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# NO CHECKED-IN PROTOBUF GENCODE
# source: typed/v1/typed.proto
# Protobuf Python Version: 6.30.2
"""Generated protocol buffer code."""
from google.protobuf import descriptor as _descriptor
from google.protobuf import descriptor_pool as _descriptor_pool
from google.protobuf import runtime_version as _runtime_version
from google.protobuf import symbol_database as _symbol_database
from google.protobuf.internal import builder as _builder
_runtime_version.ValidateProtobufRuntimeVersion(
    _runtime_version.Domain.PUBLIC,
    6,
    30,
    2,
    '',
    'typed/v1/typed.proto'
)
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()




DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n\x14typed/v1/typed.proto\x12\x08typed.v1\"\xfe\x01\n\x04User\x12\n\n\x02id\x18\x01 \x01(\t\x12\x0c\n\x04name\x18\x02 \x01(\t\x12\x12\n\x05\x65mail\x18\x03 \x01(\tH\x01\x88\x01\x01\x12 \n\x06status\x18\x04 \x01(\x0e\x32\x10.typed.v1.Status\x12\x0c\n\x04tags\x18\x05 \x03(\t\x12.\n\x08metadata\x18\x06 \x03(\x0b\x32\x1c.typed.v1.User.MetadataEntry\x12\x0f\n\x05phone\x18\x07 \x01(\tH\x00\x12\x11\n\x07\x64iscord\x18\x08 \x01(\tH\x00\x1a/\n\rMetadataEntry\x12\x0b\n\x03key\x18\x01 \x01(\t\x12\r\n\x05value\x18\x02 \x01(\t:\x02\x38\x01\x42\t\n\x07\x63ontactB\x08\n\x06_email\"!\n\x0eGetUserRequest\x12\x0f\n\x07user_id\x18\x01 \x01(\t\">\n\x0fGetUserResponse\x12\x1c\n\x04user\x18\x01 \x01(\x0b\x32\x0e.typed.v1.User\x12\r\n\x05\x66ound\x18\x02 \x01(\x08\"9\n\x10ListUsersRequest\x12\x11\n\tpage_size\x18\x01 \x01(\x05\x12\x12\n\npage_token\x18\x02 \x01(\t\"K\n\x11ListUsersResponse\x12\x1d\n\x05users\x18\x01 \x03(\x0b\x32\x0e.typed.v1.User\x12\x17\n\x0fnext_page_token\x18\x02 \x01(\t*/\n\x06Status\x12\x0b\n\x07UNKNOWN\x10\x00\x12\n\n\x06\x41\x43TIVE\x10\x01\x12\x0c\n\x08INACTIVE\x10\x02\x32\x93\x01\n\x0bUserService\x12>\n\x07GetUser\x12\x18.typed.v1.GetUserRequest\x1a\x19.typed.v1.GetUserResponse\x12\x44\n\tListUsers\x12\x1a.typed.v1.ListUsersRequest\x1a\x1b.typed.v1.ListUsersResponseb\x06proto3')

_globals = globals()
_builder.BuildMessageAndEnumDescriptors(DESCRIPTOR, _globals)
_builder.BuildTopDescriptorsAndMessages(DESCRIPTOR, 'typed.v1.typed_pb2', _globals)
if not _descriptor._USE_C_DESCRIPTORS:
  DESCRIPTOR._loaded_options = None
  _globals['_USER_METADATAENTRY']._loaded_options = None
  _globals['_USER_METADATAENTRY']._serialized_options = b'8\001'
  _globals['_STATUS']._serialized_start=526
  _globals['_STATUS']._serialized_end=573
  _globals['_USER']._serialized_start=35
  _globals['_USER']._serialized_end=289
  _globals['_USER_METADATAENTRY']._serialized_start=221
  _globals['_USER_METADATAENTRY']._serialized_end=268
  _globals['_GETUSERREQUEST']._serialized_start=291
  _globals['_GETUSERREQUEST']._serialized_end=324
  _globals['_GETUSERRESPONSE']._serialized_start=326
  _globals['_GETUSERRESPONSE']._serialized_end=388
  _globals['_LISTUSERSREQUEST']._serialized_start=390
  _globals['_LISTUSERSREQUEST']._serialized_end=447
  _globals['_LISTUSERSRESPONSE']._serialized_start=449
  _globals['_LISTUSERSRESPONSE']._serialized_end=524
  _globals['_USERSERVICE']._serialized_start=576
  _globals['_USERSERVICE']._serialized_end=723
# @@protoc_insertion_point(module_scope)
