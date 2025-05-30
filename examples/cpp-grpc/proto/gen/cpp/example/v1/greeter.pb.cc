// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: example/v1/greeter.proto

#include "example/v1/greeter.pb.h"

#include <algorithm>
#include "google/protobuf/io/coded_stream.h"
#include "google/protobuf/extension_set.h"
#include "google/protobuf/wire_format_lite.h"
#include "google/protobuf/descriptor.h"
#include "google/protobuf/generated_message_reflection.h"
#include "google/protobuf/reflection_ops.h"
#include "google/protobuf/wire_format.h"
#include "google/protobuf/generated_message_tctable_impl.h"
// @@protoc_insertion_point(includes)

// Must be included last.
#include "google/protobuf/port_def.inc"
PROTOBUF_PRAGMA_INIT_SEG
namespace _pb = ::google::protobuf;
namespace _pbi = ::google::protobuf::internal;
namespace _fl = ::google::protobuf::internal::field_layout;
namespace example {
namespace v1 {
        template <typename>
PROTOBUF_CONSTEXPR HelloRequest::HelloRequest(::_pbi::ConstantInitialized)
    : _impl_{
      /*decltype(_impl_._has_bits_)*/ {},
      /*decltype(_impl_._cached_size_)*/ {},
      /*decltype(_impl_.name_)*/ {
          &::_pbi::fixed_address_empty_string,
          ::_pbi::ConstantInitialized{},
      },
      /*decltype(_impl_.language_)*/ {
          &::_pbi::fixed_address_empty_string,
          ::_pbi::ConstantInitialized{},
      },
      /*decltype(_impl_.timestamp_)*/ nullptr,
    } {}
struct HelloRequestDefaultTypeInternal {
  PROTOBUF_CONSTEXPR HelloRequestDefaultTypeInternal() : _instance(::_pbi::ConstantInitialized{}) {}
  ~HelloRequestDefaultTypeInternal() {}
  union {
    HelloRequest _instance;
  };
};

PROTOBUF_ATTRIBUTE_NO_DESTROY PROTOBUF_CONSTINIT
    PROTOBUF_ATTRIBUTE_INIT_PRIORITY1 HelloRequestDefaultTypeInternal _HelloRequest_default_instance_;
        template <typename>
PROTOBUF_CONSTEXPR HelloResponse::HelloResponse(::_pbi::ConstantInitialized)
    : _impl_{
      /*decltype(_impl_._has_bits_)*/ {},
      /*decltype(_impl_._cached_size_)*/ {},
      /*decltype(_impl_.message_)*/ {
          &::_pbi::fixed_address_empty_string,
          ::_pbi::ConstantInitialized{},
      },
      /*decltype(_impl_.language_)*/ {
          &::_pbi::fixed_address_empty_string,
          ::_pbi::ConstantInitialized{},
      },
      /*decltype(_impl_.server_timestamp_)*/ nullptr,
      /*decltype(_impl_.response_count_)*/ 0,
    } {}
struct HelloResponseDefaultTypeInternal {
  PROTOBUF_CONSTEXPR HelloResponseDefaultTypeInternal() : _instance(::_pbi::ConstantInitialized{}) {}
  ~HelloResponseDefaultTypeInternal() {}
  union {
    HelloResponse _instance;
  };
};

PROTOBUF_ATTRIBUTE_NO_DESTROY PROTOBUF_CONSTINIT
    PROTOBUF_ATTRIBUTE_INIT_PRIORITY1 HelloResponseDefaultTypeInternal _HelloResponse_default_instance_;
}  // namespace v1
}  // namespace example
static ::_pb::Metadata file_level_metadata_example_2fv1_2fgreeter_2eproto[2];
static constexpr const ::_pb::EnumDescriptor**
    file_level_enum_descriptors_example_2fv1_2fgreeter_2eproto = nullptr;
static constexpr const ::_pb::ServiceDescriptor**
    file_level_service_descriptors_example_2fv1_2fgreeter_2eproto = nullptr;
const ::uint32_t TableStruct_example_2fv1_2fgreeter_2eproto::offsets[] PROTOBUF_SECTION_VARIABLE(
    protodesc_cold) = {
    PROTOBUF_FIELD_OFFSET(::example::v1::HelloRequest, _impl_._has_bits_),
    PROTOBUF_FIELD_OFFSET(::example::v1::HelloRequest, _internal_metadata_),
    ~0u,  // no _extensions_
    ~0u,  // no _oneof_case_
    ~0u,  // no _weak_field_map_
    ~0u,  // no _inlined_string_donated_
    ~0u,  // no _split_
    ~0u,  // no sizeof(Split)
    PROTOBUF_FIELD_OFFSET(::example::v1::HelloRequest, _impl_.name_),
    PROTOBUF_FIELD_OFFSET(::example::v1::HelloRequest, _impl_.language_),
    PROTOBUF_FIELD_OFFSET(::example::v1::HelloRequest, _impl_.timestamp_),
    ~0u,
    ~0u,
    0,
    PROTOBUF_FIELD_OFFSET(::example::v1::HelloResponse, _impl_._has_bits_),
    PROTOBUF_FIELD_OFFSET(::example::v1::HelloResponse, _internal_metadata_),
    ~0u,  // no _extensions_
    ~0u,  // no _oneof_case_
    ~0u,  // no _weak_field_map_
    ~0u,  // no _inlined_string_donated_
    ~0u,  // no _split_
    ~0u,  // no sizeof(Split)
    PROTOBUF_FIELD_OFFSET(::example::v1::HelloResponse, _impl_.message_),
    PROTOBUF_FIELD_OFFSET(::example::v1::HelloResponse, _impl_.language_),
    PROTOBUF_FIELD_OFFSET(::example::v1::HelloResponse, _impl_.server_timestamp_),
    PROTOBUF_FIELD_OFFSET(::example::v1::HelloResponse, _impl_.response_count_),
    ~0u,
    ~0u,
    0,
    ~0u,
};

static const ::_pbi::MigrationSchema
    schemas[] PROTOBUF_SECTION_VARIABLE(protodesc_cold) = {
        {0, 11, -1, sizeof(::example::v1::HelloRequest)},
        {14, 26, -1, sizeof(::example::v1::HelloResponse)},
};

static const ::_pb::Message* const file_default_instances[] = {
    &::example::v1::_HelloRequest_default_instance_._instance,
    &::example::v1::_HelloResponse_default_instance_._instance,
};
const char descriptor_table_protodef_example_2fv1_2fgreeter_2eproto[] PROTOBUF_SECTION_VARIABLE(protodesc_cold) = {
    "\n\030example/v1/greeter.proto\022\nexample.v1\032\037"
    "google/protobuf/timestamp.proto\"]\n\014Hello"
    "Request\022\014\n\004name\030\001 \001(\t\022\020\n\010language\030\002 \001(\t\022"
    "-\n\ttimestamp\030\003 \001(\0132\032.google.protobuf.Tim"
    "estamp\"\200\001\n\rHelloResponse\022\017\n\007message\030\001 \001("
    "\t\022\020\n\010language\030\002 \001(\t\0224\n\020server_timestamp\030"
    "\003 \001(\0132\032.google.protobuf.Timestamp\022\026\n\016res"
    "ponse_count\030\004 \001(\0052\262\002\n\016GreeterService\022\?\n\010"
    "SayHello\022\030.example.v1.HelloRequest\032\031.exa"
    "mple.v1.HelloResponse\022G\n\016SayHelloStream\022"
    "\030.example.v1.HelloRequest\032\031.example.v1.H"
    "elloResponse0\001\022M\n\024SayHelloClientStream\022\030"
    ".example.v1.HelloRequest\032\031.example.v1.He"
    "lloResponse(\001\022G\n\014SayHelloBidi\022\030.example."
    "v1.HelloRequest\032\031.example.v1.HelloRespon"
    "se(\0010\001b\006proto3"
};
static const ::_pbi::DescriptorTable* const descriptor_table_example_2fv1_2fgreeter_2eproto_deps[1] =
    {
        &::descriptor_table_google_2fprotobuf_2ftimestamp_2eproto,
};
static ::absl::once_flag descriptor_table_example_2fv1_2fgreeter_2eproto_once;
const ::_pbi::DescriptorTable descriptor_table_example_2fv1_2fgreeter_2eproto = {
    false,
    false,
    614,
    descriptor_table_protodef_example_2fv1_2fgreeter_2eproto,
    "example/v1/greeter.proto",
    &descriptor_table_example_2fv1_2fgreeter_2eproto_once,
    descriptor_table_example_2fv1_2fgreeter_2eproto_deps,
    1,
    2,
    schemas,
    file_default_instances,
    TableStruct_example_2fv1_2fgreeter_2eproto::offsets,
    file_level_metadata_example_2fv1_2fgreeter_2eproto,
    file_level_enum_descriptors_example_2fv1_2fgreeter_2eproto,
    file_level_service_descriptors_example_2fv1_2fgreeter_2eproto,
};

// This function exists to be marked as weak.
// It can significantly speed up compilation by breaking up LLVM's SCC
// in the .pb.cc translation units. Large translation units see a
// reduction of more than 35% of walltime for optimized builds. Without
// the weak attribute all the messages in the file, including all the
// vtables and everything they use become part of the same SCC through
// a cycle like:
// GetMetadata -> descriptor table -> default instances ->
//   vtables -> GetMetadata
// By adding a weak function here we break the connection from the
// individual vtables back into the descriptor table.
PROTOBUF_ATTRIBUTE_WEAK const ::_pbi::DescriptorTable* descriptor_table_example_2fv1_2fgreeter_2eproto_getter() {
  return &descriptor_table_example_2fv1_2fgreeter_2eproto;
}
// Force running AddDescriptors() at dynamic initialization time.
PROTOBUF_ATTRIBUTE_INIT_PRIORITY2
static ::_pbi::AddDescriptorsRunner dynamic_init_dummy_example_2fv1_2fgreeter_2eproto(&descriptor_table_example_2fv1_2fgreeter_2eproto);
namespace example {
namespace v1 {
// ===================================================================

class HelloRequest::_Internal {
 public:
  using HasBits = decltype(std::declval<HelloRequest>()._impl_._has_bits_);
  static constexpr ::int32_t kHasBitsOffset =
    8 * PROTOBUF_FIELD_OFFSET(HelloRequest, _impl_._has_bits_);
  static const ::google::protobuf::Timestamp& timestamp(const HelloRequest* msg);
  static void set_has_timestamp(HasBits* has_bits) {
    (*has_bits)[0] |= 1u;
  }
};

const ::google::protobuf::Timestamp& HelloRequest::_Internal::timestamp(const HelloRequest* msg) {
  return *msg->_impl_.timestamp_;
}
void HelloRequest::clear_timestamp() {
  if (_impl_.timestamp_ != nullptr) _impl_.timestamp_->Clear();
  _impl_._has_bits_[0] &= ~0x00000001u;
}
HelloRequest::HelloRequest(::google::protobuf::Arena* arena)
    : ::google::protobuf::Message(arena) {
  SharedCtor(arena);
  // @@protoc_insertion_point(arena_constructor:example.v1.HelloRequest)
}
HelloRequest::HelloRequest(const HelloRequest& from) : ::google::protobuf::Message() {
  HelloRequest* const _this = this;
  (void)_this;
  new (&_impl_) Impl_{
      decltype(_impl_._has_bits_){from._impl_._has_bits_},
      /*decltype(_impl_._cached_size_)*/ {},
      decltype(_impl_.name_){},
      decltype(_impl_.language_){},
      decltype(_impl_.timestamp_){nullptr},
  };
  _internal_metadata_.MergeFrom<::google::protobuf::UnknownFieldSet>(
      from._internal_metadata_);
  _impl_.name_.InitDefault();
  #ifdef PROTOBUF_FORCE_COPY_DEFAULT_STRING
        _impl_.name_.Set("", GetArenaForAllocation());
  #endif  // PROTOBUF_FORCE_COPY_DEFAULT_STRING
  if (!from._internal_name().empty()) {
    _this->_impl_.name_.Set(from._internal_name(), _this->GetArenaForAllocation());
  }
  _impl_.language_.InitDefault();
  #ifdef PROTOBUF_FORCE_COPY_DEFAULT_STRING
        _impl_.language_.Set("", GetArenaForAllocation());
  #endif  // PROTOBUF_FORCE_COPY_DEFAULT_STRING
  if (!from._internal_language().empty()) {
    _this->_impl_.language_.Set(from._internal_language(), _this->GetArenaForAllocation());
  }
  if ((from._impl_._has_bits_[0] & 0x00000001u) != 0) {
    _this->_impl_.timestamp_ = new ::google::protobuf::Timestamp(*from._impl_.timestamp_);
  }

  // @@protoc_insertion_point(copy_constructor:example.v1.HelloRequest)
}
inline void HelloRequest::SharedCtor(::_pb::Arena* arena) {
  (void)arena;
  new (&_impl_) Impl_{
      decltype(_impl_._has_bits_){},
      /*decltype(_impl_._cached_size_)*/ {},
      decltype(_impl_.name_){},
      decltype(_impl_.language_){},
      decltype(_impl_.timestamp_){nullptr},
  };
  _impl_.name_.InitDefault();
  #ifdef PROTOBUF_FORCE_COPY_DEFAULT_STRING
        _impl_.name_.Set("", GetArenaForAllocation());
  #endif  // PROTOBUF_FORCE_COPY_DEFAULT_STRING
  _impl_.language_.InitDefault();
  #ifdef PROTOBUF_FORCE_COPY_DEFAULT_STRING
        _impl_.language_.Set("", GetArenaForAllocation());
  #endif  // PROTOBUF_FORCE_COPY_DEFAULT_STRING
}
HelloRequest::~HelloRequest() {
  // @@protoc_insertion_point(destructor:example.v1.HelloRequest)
  _internal_metadata_.Delete<::google::protobuf::UnknownFieldSet>();
  SharedDtor();
}
inline void HelloRequest::SharedDtor() {
  ABSL_DCHECK(GetArenaForAllocation() == nullptr);
  _impl_.name_.Destroy();
  _impl_.language_.Destroy();
  if (this != internal_default_instance()) delete _impl_.timestamp_;
}
void HelloRequest::SetCachedSize(int size) const {
  _impl_._cached_size_.Set(size);
}

PROTOBUF_NOINLINE void HelloRequest::Clear() {
// @@protoc_insertion_point(message_clear_start:example.v1.HelloRequest)
  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  _impl_.name_.ClearToEmpty();
  _impl_.language_.ClearToEmpty();
  cached_has_bits = _impl_._has_bits_[0];
  if (cached_has_bits & 0x00000001u) {
    ABSL_DCHECK(_impl_.timestamp_ != nullptr);
    _impl_.timestamp_->Clear();
  }
  _impl_._has_bits_.Clear();
  _internal_metadata_.Clear<::google::protobuf::UnknownFieldSet>();
}

const char* HelloRequest::_InternalParse(
    const char* ptr, ::_pbi::ParseContext* ctx) {
  ptr = ::_pbi::TcParser::ParseLoop(this, ptr, ctx, &_table_.header);
  return ptr;
}


PROTOBUF_CONSTINIT PROTOBUF_ATTRIBUTE_INIT_PRIORITY1
const ::_pbi::TcParseTable<2, 3, 1, 44, 2> HelloRequest::_table_ = {
  {
    PROTOBUF_FIELD_OFFSET(HelloRequest, _impl_._has_bits_),
    0, // no _extensions_
    3, 24,  // max_field_number, fast_idx_mask
    offsetof(decltype(_table_), field_lookup_table),
    4294967288,  // skipmap
    offsetof(decltype(_table_), field_entries),
    3,  // num_field_entries
    1,  // num_aux_entries
    offsetof(decltype(_table_), aux_entries),
    &_HelloRequest_default_instance_._instance,
    ::_pbi::TcParser::GenericFallback,  // fallback
  }, {{
    {::_pbi::TcParser::MiniParse, {}},
    // string name = 1;
    {::_pbi::TcParser::FastUS1,
     {10, 63, 0, PROTOBUF_FIELD_OFFSET(HelloRequest, _impl_.name_)}},
    // string language = 2;
    {::_pbi::TcParser::FastUS1,
     {18, 63, 0, PROTOBUF_FIELD_OFFSET(HelloRequest, _impl_.language_)}},
    // .google.protobuf.Timestamp timestamp = 3;
    {::_pbi::TcParser::FastMtS1,
     {26, 0, 0, PROTOBUF_FIELD_OFFSET(HelloRequest, _impl_.timestamp_)}},
  }}, {{
    65535, 65535
  }}, {{
    // string name = 1;
    {PROTOBUF_FIELD_OFFSET(HelloRequest, _impl_.name_), -1, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kUtf8String | ::_fl::kRepAString)},
    // string language = 2;
    {PROTOBUF_FIELD_OFFSET(HelloRequest, _impl_.language_), -1, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kUtf8String | ::_fl::kRepAString)},
    // .google.protobuf.Timestamp timestamp = 3;
    {PROTOBUF_FIELD_OFFSET(HelloRequest, _impl_.timestamp_), _Internal::kHasBitsOffset + 0, 0,
    (0 | ::_fl::kFcOptional | ::_fl::kMessage | ::_fl::kTvTable)},
  }}, {{
    {::_pbi::TcParser::GetTable<::google::protobuf::Timestamp>()},
  }}, {{
    "\27\4\10\0\0\0\0\0"
    "example.v1.HelloRequest"
    "name"
    "language"
  }},
};

::uint8_t* HelloRequest::_InternalSerialize(
    ::uint8_t* target,
    ::google::protobuf::io::EpsCopyOutputStream* stream) const {
  // @@protoc_insertion_point(serialize_to_array_start:example.v1.HelloRequest)
  ::uint32_t cached_has_bits = 0;
  (void)cached_has_bits;

  // string name = 1;
  if (!this->_internal_name().empty()) {
    const std::string& _s = this->_internal_name();
    ::google::protobuf::internal::WireFormatLite::VerifyUtf8String(
        _s.data(), static_cast<int>(_s.length()), ::google::protobuf::internal::WireFormatLite::SERIALIZE, "example.v1.HelloRequest.name");
    target = stream->WriteStringMaybeAliased(1, _s, target);
  }

  // string language = 2;
  if (!this->_internal_language().empty()) {
    const std::string& _s = this->_internal_language();
    ::google::protobuf::internal::WireFormatLite::VerifyUtf8String(
        _s.data(), static_cast<int>(_s.length()), ::google::protobuf::internal::WireFormatLite::SERIALIZE, "example.v1.HelloRequest.language");
    target = stream->WriteStringMaybeAliased(2, _s, target);
  }

  cached_has_bits = _impl_._has_bits_[0];
  // .google.protobuf.Timestamp timestamp = 3;
  if (cached_has_bits & 0x00000001u) {
    target = ::google::protobuf::internal::WireFormatLite::
      InternalWriteMessage(3, _Internal::timestamp(this),
        _Internal::timestamp(this).GetCachedSize(), target, stream);
  }

  if (PROTOBUF_PREDICT_FALSE(_internal_metadata_.have_unknown_fields())) {
    target =
        ::_pbi::WireFormat::InternalSerializeUnknownFieldsToArray(
            _internal_metadata_.unknown_fields<::google::protobuf::UnknownFieldSet>(::google::protobuf::UnknownFieldSet::default_instance), target, stream);
  }
  // @@protoc_insertion_point(serialize_to_array_end:example.v1.HelloRequest)
  return target;
}

::size_t HelloRequest::ByteSizeLong() const {
// @@protoc_insertion_point(message_byte_size_start:example.v1.HelloRequest)
  ::size_t total_size = 0;

  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  // string name = 1;
  if (!this->_internal_name().empty()) {
    total_size += 1 + ::google::protobuf::internal::WireFormatLite::StringSize(
                                    this->_internal_name());
  }

  // string language = 2;
  if (!this->_internal_language().empty()) {
    total_size += 1 + ::google::protobuf::internal::WireFormatLite::StringSize(
                                    this->_internal_language());
  }

  // .google.protobuf.Timestamp timestamp = 3;
  cached_has_bits = _impl_._has_bits_[0];
  if (cached_has_bits & 0x00000001u) {
    total_size += 1 +
      ::google::protobuf::internal::WireFormatLite::MessageSize(
        *_impl_.timestamp_);
  }

  return MaybeComputeUnknownFieldsSize(total_size, &_impl_._cached_size_);
}

const ::google::protobuf::Message::ClassData HelloRequest::_class_data_ = {
    ::google::protobuf::Message::CopyWithSourceCheck,
    HelloRequest::MergeImpl
};
const ::google::protobuf::Message::ClassData*HelloRequest::GetClassData() const { return &_class_data_; }


void HelloRequest::MergeImpl(::google::protobuf::Message& to_msg, const ::google::protobuf::Message& from_msg) {
  auto* const _this = static_cast<HelloRequest*>(&to_msg);
  auto& from = static_cast<const HelloRequest&>(from_msg);
  // @@protoc_insertion_point(class_specific_merge_from_start:example.v1.HelloRequest)
  ABSL_DCHECK_NE(&from, _this);
  ::uint32_t cached_has_bits = 0;
  (void) cached_has_bits;

  if (!from._internal_name().empty()) {
    _this->_internal_set_name(from._internal_name());
  }
  if (!from._internal_language().empty()) {
    _this->_internal_set_language(from._internal_language());
  }
  if ((from._impl_._has_bits_[0] & 0x00000001u) != 0) {
    _this->_internal_mutable_timestamp()->::google::protobuf::Timestamp::MergeFrom(
        from._internal_timestamp());
  }
  _this->_internal_metadata_.MergeFrom<::google::protobuf::UnknownFieldSet>(from._internal_metadata_);
}

void HelloRequest::CopyFrom(const HelloRequest& from) {
// @@protoc_insertion_point(class_specific_copy_from_start:example.v1.HelloRequest)
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

PROTOBUF_NOINLINE bool HelloRequest::IsInitialized() const {
  return true;
}

void HelloRequest::InternalSwap(HelloRequest* other) {
  using std::swap;
  auto* lhs_arena = GetArenaForAllocation();
  auto* rhs_arena = other->GetArenaForAllocation();
  _internal_metadata_.InternalSwap(&other->_internal_metadata_);
  swap(_impl_._has_bits_[0], other->_impl_._has_bits_[0]);
  ::_pbi::ArenaStringPtr::InternalSwap(&_impl_.name_, lhs_arena,
                                       &other->_impl_.name_, rhs_arena);
  ::_pbi::ArenaStringPtr::InternalSwap(&_impl_.language_, lhs_arena,
                                       &other->_impl_.language_, rhs_arena);
  swap(_impl_.timestamp_, other->_impl_.timestamp_);
}

::google::protobuf::Metadata HelloRequest::GetMetadata() const {
  return ::_pbi::AssignDescriptors(
      &descriptor_table_example_2fv1_2fgreeter_2eproto_getter, &descriptor_table_example_2fv1_2fgreeter_2eproto_once,
      file_level_metadata_example_2fv1_2fgreeter_2eproto[0]);
}
// ===================================================================

class HelloResponse::_Internal {
 public:
  using HasBits = decltype(std::declval<HelloResponse>()._impl_._has_bits_);
  static constexpr ::int32_t kHasBitsOffset =
    8 * PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_._has_bits_);
  static const ::google::protobuf::Timestamp& server_timestamp(const HelloResponse* msg);
  static void set_has_server_timestamp(HasBits* has_bits) {
    (*has_bits)[0] |= 1u;
  }
};

const ::google::protobuf::Timestamp& HelloResponse::_Internal::server_timestamp(const HelloResponse* msg) {
  return *msg->_impl_.server_timestamp_;
}
void HelloResponse::clear_server_timestamp() {
  if (_impl_.server_timestamp_ != nullptr) _impl_.server_timestamp_->Clear();
  _impl_._has_bits_[0] &= ~0x00000001u;
}
HelloResponse::HelloResponse(::google::protobuf::Arena* arena)
    : ::google::protobuf::Message(arena) {
  SharedCtor(arena);
  // @@protoc_insertion_point(arena_constructor:example.v1.HelloResponse)
}
HelloResponse::HelloResponse(const HelloResponse& from) : ::google::protobuf::Message() {
  HelloResponse* const _this = this;
  (void)_this;
  new (&_impl_) Impl_{
      decltype(_impl_._has_bits_){from._impl_._has_bits_},
      /*decltype(_impl_._cached_size_)*/ {},
      decltype(_impl_.message_){},
      decltype(_impl_.language_){},
      decltype(_impl_.server_timestamp_){nullptr},
      decltype(_impl_.response_count_){},
  };
  _internal_metadata_.MergeFrom<::google::protobuf::UnknownFieldSet>(
      from._internal_metadata_);
  _impl_.message_.InitDefault();
  #ifdef PROTOBUF_FORCE_COPY_DEFAULT_STRING
        _impl_.message_.Set("", GetArenaForAllocation());
  #endif  // PROTOBUF_FORCE_COPY_DEFAULT_STRING
  if (!from._internal_message().empty()) {
    _this->_impl_.message_.Set(from._internal_message(), _this->GetArenaForAllocation());
  }
  _impl_.language_.InitDefault();
  #ifdef PROTOBUF_FORCE_COPY_DEFAULT_STRING
        _impl_.language_.Set("", GetArenaForAllocation());
  #endif  // PROTOBUF_FORCE_COPY_DEFAULT_STRING
  if (!from._internal_language().empty()) {
    _this->_impl_.language_.Set(from._internal_language(), _this->GetArenaForAllocation());
  }
  if ((from._impl_._has_bits_[0] & 0x00000001u) != 0) {
    _this->_impl_.server_timestamp_ = new ::google::protobuf::Timestamp(*from._impl_.server_timestamp_);
  }
  _this->_impl_.response_count_ = from._impl_.response_count_;

  // @@protoc_insertion_point(copy_constructor:example.v1.HelloResponse)
}
inline void HelloResponse::SharedCtor(::_pb::Arena* arena) {
  (void)arena;
  new (&_impl_) Impl_{
      decltype(_impl_._has_bits_){},
      /*decltype(_impl_._cached_size_)*/ {},
      decltype(_impl_.message_){},
      decltype(_impl_.language_){},
      decltype(_impl_.server_timestamp_){nullptr},
      decltype(_impl_.response_count_){0},
  };
  _impl_.message_.InitDefault();
  #ifdef PROTOBUF_FORCE_COPY_DEFAULT_STRING
        _impl_.message_.Set("", GetArenaForAllocation());
  #endif  // PROTOBUF_FORCE_COPY_DEFAULT_STRING
  _impl_.language_.InitDefault();
  #ifdef PROTOBUF_FORCE_COPY_DEFAULT_STRING
        _impl_.language_.Set("", GetArenaForAllocation());
  #endif  // PROTOBUF_FORCE_COPY_DEFAULT_STRING
}
HelloResponse::~HelloResponse() {
  // @@protoc_insertion_point(destructor:example.v1.HelloResponse)
  _internal_metadata_.Delete<::google::protobuf::UnknownFieldSet>();
  SharedDtor();
}
inline void HelloResponse::SharedDtor() {
  ABSL_DCHECK(GetArenaForAllocation() == nullptr);
  _impl_.message_.Destroy();
  _impl_.language_.Destroy();
  if (this != internal_default_instance()) delete _impl_.server_timestamp_;
}
void HelloResponse::SetCachedSize(int size) const {
  _impl_._cached_size_.Set(size);
}

PROTOBUF_NOINLINE void HelloResponse::Clear() {
// @@protoc_insertion_point(message_clear_start:example.v1.HelloResponse)
  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  _impl_.message_.ClearToEmpty();
  _impl_.language_.ClearToEmpty();
  cached_has_bits = _impl_._has_bits_[0];
  if (cached_has_bits & 0x00000001u) {
    ABSL_DCHECK(_impl_.server_timestamp_ != nullptr);
    _impl_.server_timestamp_->Clear();
  }
  _impl_.response_count_ = 0;
  _impl_._has_bits_.Clear();
  _internal_metadata_.Clear<::google::protobuf::UnknownFieldSet>();
}

const char* HelloResponse::_InternalParse(
    const char* ptr, ::_pbi::ParseContext* ctx) {
  ptr = ::_pbi::TcParser::ParseLoop(this, ptr, ctx, &_table_.header);
  return ptr;
}


PROTOBUF_CONSTINIT PROTOBUF_ATTRIBUTE_INIT_PRIORITY1
const ::_pbi::TcParseTable<2, 4, 1, 48, 2> HelloResponse::_table_ = {
  {
    PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_._has_bits_),
    0, // no _extensions_
    4, 24,  // max_field_number, fast_idx_mask
    offsetof(decltype(_table_), field_lookup_table),
    4294967280,  // skipmap
    offsetof(decltype(_table_), field_entries),
    4,  // num_field_entries
    1,  // num_aux_entries
    offsetof(decltype(_table_), aux_entries),
    &_HelloResponse_default_instance_._instance,
    ::_pbi::TcParser::GenericFallback,  // fallback
  }, {{
    // int32 response_count = 4;
    {::_pbi::TcParser::SingularVarintNoZag1<::uint32_t, offsetof(HelloResponse, _impl_.response_count_), 63>(),
     {32, 63, 0, PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_.response_count_)}},
    // string message = 1;
    {::_pbi::TcParser::FastUS1,
     {10, 63, 0, PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_.message_)}},
    // string language = 2;
    {::_pbi::TcParser::FastUS1,
     {18, 63, 0, PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_.language_)}},
    // .google.protobuf.Timestamp server_timestamp = 3;
    {::_pbi::TcParser::FastMtS1,
     {26, 0, 0, PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_.server_timestamp_)}},
  }}, {{
    65535, 65535
  }}, {{
    // string message = 1;
    {PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_.message_), -1, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kUtf8String | ::_fl::kRepAString)},
    // string language = 2;
    {PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_.language_), -1, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kUtf8String | ::_fl::kRepAString)},
    // .google.protobuf.Timestamp server_timestamp = 3;
    {PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_.server_timestamp_), _Internal::kHasBitsOffset + 0, 0,
    (0 | ::_fl::kFcOptional | ::_fl::kMessage | ::_fl::kTvTable)},
    // int32 response_count = 4;
    {PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_.response_count_), -1, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kInt32)},
  }}, {{
    {::_pbi::TcParser::GetTable<::google::protobuf::Timestamp>()},
  }}, {{
    "\30\7\10\0\0\0\0\0"
    "example.v1.HelloResponse"
    "message"
    "language"
  }},
};

::uint8_t* HelloResponse::_InternalSerialize(
    ::uint8_t* target,
    ::google::protobuf::io::EpsCopyOutputStream* stream) const {
  // @@protoc_insertion_point(serialize_to_array_start:example.v1.HelloResponse)
  ::uint32_t cached_has_bits = 0;
  (void)cached_has_bits;

  // string message = 1;
  if (!this->_internal_message().empty()) {
    const std::string& _s = this->_internal_message();
    ::google::protobuf::internal::WireFormatLite::VerifyUtf8String(
        _s.data(), static_cast<int>(_s.length()), ::google::protobuf::internal::WireFormatLite::SERIALIZE, "example.v1.HelloResponse.message");
    target = stream->WriteStringMaybeAliased(1, _s, target);
  }

  // string language = 2;
  if (!this->_internal_language().empty()) {
    const std::string& _s = this->_internal_language();
    ::google::protobuf::internal::WireFormatLite::VerifyUtf8String(
        _s.data(), static_cast<int>(_s.length()), ::google::protobuf::internal::WireFormatLite::SERIALIZE, "example.v1.HelloResponse.language");
    target = stream->WriteStringMaybeAliased(2, _s, target);
  }

  cached_has_bits = _impl_._has_bits_[0];
  // .google.protobuf.Timestamp server_timestamp = 3;
  if (cached_has_bits & 0x00000001u) {
    target = ::google::protobuf::internal::WireFormatLite::
      InternalWriteMessage(3, _Internal::server_timestamp(this),
        _Internal::server_timestamp(this).GetCachedSize(), target, stream);
  }

  // int32 response_count = 4;
  if (this->_internal_response_count() != 0) {
    target = ::google::protobuf::internal::WireFormatLite::
        WriteInt32ToArrayWithField<4>(
            stream, this->_internal_response_count(), target);
  }

  if (PROTOBUF_PREDICT_FALSE(_internal_metadata_.have_unknown_fields())) {
    target =
        ::_pbi::WireFormat::InternalSerializeUnknownFieldsToArray(
            _internal_metadata_.unknown_fields<::google::protobuf::UnknownFieldSet>(::google::protobuf::UnknownFieldSet::default_instance), target, stream);
  }
  // @@protoc_insertion_point(serialize_to_array_end:example.v1.HelloResponse)
  return target;
}

::size_t HelloResponse::ByteSizeLong() const {
// @@protoc_insertion_point(message_byte_size_start:example.v1.HelloResponse)
  ::size_t total_size = 0;

  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  // string message = 1;
  if (!this->_internal_message().empty()) {
    total_size += 1 + ::google::protobuf::internal::WireFormatLite::StringSize(
                                    this->_internal_message());
  }

  // string language = 2;
  if (!this->_internal_language().empty()) {
    total_size += 1 + ::google::protobuf::internal::WireFormatLite::StringSize(
                                    this->_internal_language());
  }

  // .google.protobuf.Timestamp server_timestamp = 3;
  cached_has_bits = _impl_._has_bits_[0];
  if (cached_has_bits & 0x00000001u) {
    total_size += 1 +
      ::google::protobuf::internal::WireFormatLite::MessageSize(
        *_impl_.server_timestamp_);
  }

  // int32 response_count = 4;
  if (this->_internal_response_count() != 0) {
    total_size += ::_pbi::WireFormatLite::Int32SizePlusOne(
        this->_internal_response_count());
  }

  return MaybeComputeUnknownFieldsSize(total_size, &_impl_._cached_size_);
}

const ::google::protobuf::Message::ClassData HelloResponse::_class_data_ = {
    ::google::protobuf::Message::CopyWithSourceCheck,
    HelloResponse::MergeImpl
};
const ::google::protobuf::Message::ClassData*HelloResponse::GetClassData() const { return &_class_data_; }


void HelloResponse::MergeImpl(::google::protobuf::Message& to_msg, const ::google::protobuf::Message& from_msg) {
  auto* const _this = static_cast<HelloResponse*>(&to_msg);
  auto& from = static_cast<const HelloResponse&>(from_msg);
  // @@protoc_insertion_point(class_specific_merge_from_start:example.v1.HelloResponse)
  ABSL_DCHECK_NE(&from, _this);
  ::uint32_t cached_has_bits = 0;
  (void) cached_has_bits;

  if (!from._internal_message().empty()) {
    _this->_internal_set_message(from._internal_message());
  }
  if (!from._internal_language().empty()) {
    _this->_internal_set_language(from._internal_language());
  }
  if ((from._impl_._has_bits_[0] & 0x00000001u) != 0) {
    _this->_internal_mutable_server_timestamp()->::google::protobuf::Timestamp::MergeFrom(
        from._internal_server_timestamp());
  }
  if (from._internal_response_count() != 0) {
    _this->_internal_set_response_count(from._internal_response_count());
  }
  _this->_internal_metadata_.MergeFrom<::google::protobuf::UnknownFieldSet>(from._internal_metadata_);
}

void HelloResponse::CopyFrom(const HelloResponse& from) {
// @@protoc_insertion_point(class_specific_copy_from_start:example.v1.HelloResponse)
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

PROTOBUF_NOINLINE bool HelloResponse::IsInitialized() const {
  return true;
}

void HelloResponse::InternalSwap(HelloResponse* other) {
  using std::swap;
  auto* lhs_arena = GetArenaForAllocation();
  auto* rhs_arena = other->GetArenaForAllocation();
  _internal_metadata_.InternalSwap(&other->_internal_metadata_);
  swap(_impl_._has_bits_[0], other->_impl_._has_bits_[0]);
  ::_pbi::ArenaStringPtr::InternalSwap(&_impl_.message_, lhs_arena,
                                       &other->_impl_.message_, rhs_arena);
  ::_pbi::ArenaStringPtr::InternalSwap(&_impl_.language_, lhs_arena,
                                       &other->_impl_.language_, rhs_arena);
  ::google::protobuf::internal::memswap<
      PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_.response_count_)
      + sizeof(HelloResponse::_impl_.response_count_)
      - PROTOBUF_FIELD_OFFSET(HelloResponse, _impl_.server_timestamp_)>(
          reinterpret_cast<char*>(&_impl_.server_timestamp_),
          reinterpret_cast<char*>(&other->_impl_.server_timestamp_));
}

::google::protobuf::Metadata HelloResponse::GetMetadata() const {
  return ::_pbi::AssignDescriptors(
      &descriptor_table_example_2fv1_2fgreeter_2eproto_getter, &descriptor_table_example_2fv1_2fgreeter_2eproto_once,
      file_level_metadata_example_2fv1_2fgreeter_2eproto[1]);
}
// @@protoc_insertion_point(namespace_scope)
}  // namespace v1
}  // namespace example
namespace google {
namespace protobuf {
}  // namespace protobuf
}  // namespace google
// @@protoc_insertion_point(global_scope)
#include "google/protobuf/port_undef.inc"
