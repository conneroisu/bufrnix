// Generated by the protocol buffer compiler.  DO NOT EDIT!
// NO CHECKED-IN PROTOBUF GENCODE
// source: example/v1/user.proto
// Protobuf Java Version: 4.30.2

package com.example.protos.v1;

/**
 * Protobuf type {@code example.v1.PersonalProfile}
 */
public final class PersonalProfile extends
    com.google.protobuf.GeneratedMessage implements
    // @@protoc_insertion_point(message_implements:example.v1.PersonalProfile)
    PersonalProfileOrBuilder {
private static final long serialVersionUID = 0L;
  static {
    com.google.protobuf.RuntimeVersion.validateProtobufGencodeVersion(
      com.google.protobuf.RuntimeVersion.RuntimeDomain.PUBLIC,
      /* major= */ 4,
      /* minor= */ 30,
      /* patch= */ 2,
      /* suffix= */ "",
      PersonalProfile.class.getName());
  }
  // Use PersonalProfile.newBuilder() to construct.
  private PersonalProfile(com.google.protobuf.GeneratedMessage.Builder<?> builder) {
    super(builder);
  }
  private PersonalProfile() {
    dateOfBirth_ = "";
    hobbies_ =
        com.google.protobuf.LazyStringArrayList.emptyList();
  }

  public static final com.google.protobuf.Descriptors.Descriptor
      getDescriptor() {
    return com.example.protos.v1.UserProto.internal_static_example_v1_PersonalProfile_descriptor;
  }

  @java.lang.Override
  protected com.google.protobuf.GeneratedMessage.FieldAccessorTable
      internalGetFieldAccessorTable() {
    return com.example.protos.v1.UserProto.internal_static_example_v1_PersonalProfile_fieldAccessorTable
        .ensureFieldAccessorsInitialized(
            com.example.protos.v1.PersonalProfile.class, com.example.protos.v1.PersonalProfile.Builder.class);
  }

  public static final int DATE_OF_BIRTH_FIELD_NUMBER = 1;
  @SuppressWarnings("serial")
  private volatile java.lang.Object dateOfBirth_ = "";
  /**
   * <code>string date_of_birth = 1;</code>
   * @return The dateOfBirth.
   */
  @java.lang.Override
  public java.lang.String getDateOfBirth() {
    java.lang.Object ref = dateOfBirth_;
    if (ref instanceof java.lang.String) {
      return (java.lang.String) ref;
    } else {
      com.google.protobuf.ByteString bs = 
          (com.google.protobuf.ByteString) ref;
      java.lang.String s = bs.toStringUtf8();
      dateOfBirth_ = s;
      return s;
    }
  }
  /**
   * <code>string date_of_birth = 1;</code>
   * @return The bytes for dateOfBirth.
   */
  @java.lang.Override
  public com.google.protobuf.ByteString
      getDateOfBirthBytes() {
    java.lang.Object ref = dateOfBirth_;
    if (ref instanceof java.lang.String) {
      com.google.protobuf.ByteString b = 
          com.google.protobuf.ByteString.copyFromUtf8(
              (java.lang.String) ref);
      dateOfBirth_ = b;
      return b;
    } else {
      return (com.google.protobuf.ByteString) ref;
    }
  }

  public static final int HOBBIES_FIELD_NUMBER = 2;
  @SuppressWarnings("serial")
  private com.google.protobuf.LazyStringArrayList hobbies_ =
      com.google.protobuf.LazyStringArrayList.emptyList();
  /**
   * <code>repeated string hobbies = 2;</code>
   * @return A list containing the hobbies.
   */
  public com.google.protobuf.ProtocolStringList
      getHobbiesList() {
    return hobbies_;
  }
  /**
   * <code>repeated string hobbies = 2;</code>
   * @return The count of hobbies.
   */
  public int getHobbiesCount() {
    return hobbies_.size();
  }
  /**
   * <code>repeated string hobbies = 2;</code>
   * @param index The index of the element to return.
   * @return The hobbies at the given index.
   */
  public java.lang.String getHobbies(int index) {
    return hobbies_.get(index);
  }
  /**
   * <code>repeated string hobbies = 2;</code>
   * @param index The index of the value to return.
   * @return The bytes of the hobbies at the given index.
   */
  public com.google.protobuf.ByteString
      getHobbiesBytes(int index) {
    return hobbies_.getByteString(index);
  }

  private byte memoizedIsInitialized = -1;
  @java.lang.Override
  public final boolean isInitialized() {
    byte isInitialized = memoizedIsInitialized;
    if (isInitialized == 1) return true;
    if (isInitialized == 0) return false;

    memoizedIsInitialized = 1;
    return true;
  }

  @java.lang.Override
  public void writeTo(com.google.protobuf.CodedOutputStream output)
                      throws java.io.IOException {
    if (!com.google.protobuf.GeneratedMessage.isStringEmpty(dateOfBirth_)) {
      com.google.protobuf.GeneratedMessage.writeString(output, 1, dateOfBirth_);
    }
    for (int i = 0; i < hobbies_.size(); i++) {
      com.google.protobuf.GeneratedMessage.writeString(output, 2, hobbies_.getRaw(i));
    }
    getUnknownFields().writeTo(output);
  }

  @java.lang.Override
  public int getSerializedSize() {
    int size = memoizedSize;
    if (size != -1) return size;

    size = 0;
    if (!com.google.protobuf.GeneratedMessage.isStringEmpty(dateOfBirth_)) {
      size += com.google.protobuf.GeneratedMessage.computeStringSize(1, dateOfBirth_);
    }
    {
      int dataSize = 0;
      for (int i = 0; i < hobbies_.size(); i++) {
        dataSize += computeStringSizeNoTag(hobbies_.getRaw(i));
      }
      size += dataSize;
      size += 1 * getHobbiesList().size();
    }
    size += getUnknownFields().getSerializedSize();
    memoizedSize = size;
    return size;
  }

  @java.lang.Override
  public boolean equals(final java.lang.Object obj) {
    if (obj == this) {
     return true;
    }
    if (!(obj instanceof com.example.protos.v1.PersonalProfile)) {
      return super.equals(obj);
    }
    com.example.protos.v1.PersonalProfile other = (com.example.protos.v1.PersonalProfile) obj;

    if (!getDateOfBirth()
        .equals(other.getDateOfBirth())) return false;
    if (!getHobbiesList()
        .equals(other.getHobbiesList())) return false;
    if (!getUnknownFields().equals(other.getUnknownFields())) return false;
    return true;
  }

  @java.lang.Override
  public int hashCode() {
    if (memoizedHashCode != 0) {
      return memoizedHashCode;
    }
    int hash = 41;
    hash = (19 * hash) + getDescriptor().hashCode();
    hash = (37 * hash) + DATE_OF_BIRTH_FIELD_NUMBER;
    hash = (53 * hash) + getDateOfBirth().hashCode();
    if (getHobbiesCount() > 0) {
      hash = (37 * hash) + HOBBIES_FIELD_NUMBER;
      hash = (53 * hash) + getHobbiesList().hashCode();
    }
    hash = (29 * hash) + getUnknownFields().hashCode();
    memoizedHashCode = hash;
    return hash;
  }

  public static com.example.protos.v1.PersonalProfile parseFrom(
      java.nio.ByteBuffer data)
      throws com.google.protobuf.InvalidProtocolBufferException {
    return PARSER.parseFrom(data);
  }
  public static com.example.protos.v1.PersonalProfile parseFrom(
      java.nio.ByteBuffer data,
      com.google.protobuf.ExtensionRegistryLite extensionRegistry)
      throws com.google.protobuf.InvalidProtocolBufferException {
    return PARSER.parseFrom(data, extensionRegistry);
  }
  public static com.example.protos.v1.PersonalProfile parseFrom(
      com.google.protobuf.ByteString data)
      throws com.google.protobuf.InvalidProtocolBufferException {
    return PARSER.parseFrom(data);
  }
  public static com.example.protos.v1.PersonalProfile parseFrom(
      com.google.protobuf.ByteString data,
      com.google.protobuf.ExtensionRegistryLite extensionRegistry)
      throws com.google.protobuf.InvalidProtocolBufferException {
    return PARSER.parseFrom(data, extensionRegistry);
  }
  public static com.example.protos.v1.PersonalProfile parseFrom(byte[] data)
      throws com.google.protobuf.InvalidProtocolBufferException {
    return PARSER.parseFrom(data);
  }
  public static com.example.protos.v1.PersonalProfile parseFrom(
      byte[] data,
      com.google.protobuf.ExtensionRegistryLite extensionRegistry)
      throws com.google.protobuf.InvalidProtocolBufferException {
    return PARSER.parseFrom(data, extensionRegistry);
  }
  public static com.example.protos.v1.PersonalProfile parseFrom(java.io.InputStream input)
      throws java.io.IOException {
    return com.google.protobuf.GeneratedMessage
        .parseWithIOException(PARSER, input);
  }
  public static com.example.protos.v1.PersonalProfile parseFrom(
      java.io.InputStream input,
      com.google.protobuf.ExtensionRegistryLite extensionRegistry)
      throws java.io.IOException {
    return com.google.protobuf.GeneratedMessage
        .parseWithIOException(PARSER, input, extensionRegistry);
  }

  public static com.example.protos.v1.PersonalProfile parseDelimitedFrom(java.io.InputStream input)
      throws java.io.IOException {
    return com.google.protobuf.GeneratedMessage
        .parseDelimitedWithIOException(PARSER, input);
  }

  public static com.example.protos.v1.PersonalProfile parseDelimitedFrom(
      java.io.InputStream input,
      com.google.protobuf.ExtensionRegistryLite extensionRegistry)
      throws java.io.IOException {
    return com.google.protobuf.GeneratedMessage
        .parseDelimitedWithIOException(PARSER, input, extensionRegistry);
  }
  public static com.example.protos.v1.PersonalProfile parseFrom(
      com.google.protobuf.CodedInputStream input)
      throws java.io.IOException {
    return com.google.protobuf.GeneratedMessage
        .parseWithIOException(PARSER, input);
  }
  public static com.example.protos.v1.PersonalProfile parseFrom(
      com.google.protobuf.CodedInputStream input,
      com.google.protobuf.ExtensionRegistryLite extensionRegistry)
      throws java.io.IOException {
    return com.google.protobuf.GeneratedMessage
        .parseWithIOException(PARSER, input, extensionRegistry);
  }

  @java.lang.Override
  public Builder newBuilderForType() { return newBuilder(); }
  public static Builder newBuilder() {
    return DEFAULT_INSTANCE.toBuilder();
  }
  public static Builder newBuilder(com.example.protos.v1.PersonalProfile prototype) {
    return DEFAULT_INSTANCE.toBuilder().mergeFrom(prototype);
  }
  @java.lang.Override
  public Builder toBuilder() {
    return this == DEFAULT_INSTANCE
        ? new Builder() : new Builder().mergeFrom(this);
  }

  @java.lang.Override
  protected Builder newBuilderForType(
      com.google.protobuf.GeneratedMessage.BuilderParent parent) {
    Builder builder = new Builder(parent);
    return builder;
  }
  /**
   * Protobuf type {@code example.v1.PersonalProfile}
   */
  public static final class Builder extends
      com.google.protobuf.GeneratedMessage.Builder<Builder> implements
      // @@protoc_insertion_point(builder_implements:example.v1.PersonalProfile)
      com.example.protos.v1.PersonalProfileOrBuilder {
    public static final com.google.protobuf.Descriptors.Descriptor
        getDescriptor() {
      return com.example.protos.v1.UserProto.internal_static_example_v1_PersonalProfile_descriptor;
    }

    @java.lang.Override
    protected com.google.protobuf.GeneratedMessage.FieldAccessorTable
        internalGetFieldAccessorTable() {
      return com.example.protos.v1.UserProto.internal_static_example_v1_PersonalProfile_fieldAccessorTable
          .ensureFieldAccessorsInitialized(
              com.example.protos.v1.PersonalProfile.class, com.example.protos.v1.PersonalProfile.Builder.class);
    }

    // Construct using com.example.protos.v1.PersonalProfile.newBuilder()
    private Builder() {

    }

    private Builder(
        com.google.protobuf.GeneratedMessage.BuilderParent parent) {
      super(parent);

    }
    @java.lang.Override
    public Builder clear() {
      super.clear();
      bitField0_ = 0;
      dateOfBirth_ = "";
      hobbies_ =
          com.google.protobuf.LazyStringArrayList.emptyList();
      return this;
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.Descriptor
        getDescriptorForType() {
      return com.example.protos.v1.UserProto.internal_static_example_v1_PersonalProfile_descriptor;
    }

    @java.lang.Override
    public com.example.protos.v1.PersonalProfile getDefaultInstanceForType() {
      return com.example.protos.v1.PersonalProfile.getDefaultInstance();
    }

    @java.lang.Override
    public com.example.protos.v1.PersonalProfile build() {
      com.example.protos.v1.PersonalProfile result = buildPartial();
      if (!result.isInitialized()) {
        throw newUninitializedMessageException(result);
      }
      return result;
    }

    @java.lang.Override
    public com.example.protos.v1.PersonalProfile buildPartial() {
      com.example.protos.v1.PersonalProfile result = new com.example.protos.v1.PersonalProfile(this);
      if (bitField0_ != 0) { buildPartial0(result); }
      onBuilt();
      return result;
    }

    private void buildPartial0(com.example.protos.v1.PersonalProfile result) {
      int from_bitField0_ = bitField0_;
      if (((from_bitField0_ & 0x00000001) != 0)) {
        result.dateOfBirth_ = dateOfBirth_;
      }
      if (((from_bitField0_ & 0x00000002) != 0)) {
        hobbies_.makeImmutable();
        result.hobbies_ = hobbies_;
      }
    }

    @java.lang.Override
    public Builder mergeFrom(com.google.protobuf.Message other) {
      if (other instanceof com.example.protos.v1.PersonalProfile) {
        return mergeFrom((com.example.protos.v1.PersonalProfile)other);
      } else {
        super.mergeFrom(other);
        return this;
      }
    }

    public Builder mergeFrom(com.example.protos.v1.PersonalProfile other) {
      if (other == com.example.protos.v1.PersonalProfile.getDefaultInstance()) return this;
      if (!other.getDateOfBirth().isEmpty()) {
        dateOfBirth_ = other.dateOfBirth_;
        bitField0_ |= 0x00000001;
        onChanged();
      }
      if (!other.hobbies_.isEmpty()) {
        if (hobbies_.isEmpty()) {
          hobbies_ = other.hobbies_;
          bitField0_ |= 0x00000002;
        } else {
          ensureHobbiesIsMutable();
          hobbies_.addAll(other.hobbies_);
        }
        onChanged();
      }
      this.mergeUnknownFields(other.getUnknownFields());
      onChanged();
      return this;
    }

    @java.lang.Override
    public final boolean isInitialized() {
      return true;
    }

    @java.lang.Override
    public Builder mergeFrom(
        com.google.protobuf.CodedInputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws java.io.IOException {
      if (extensionRegistry == null) {
        throw new java.lang.NullPointerException();
      }
      try {
        boolean done = false;
        while (!done) {
          int tag = input.readTag();
          switch (tag) {
            case 0:
              done = true;
              break;
            case 10: {
              dateOfBirth_ = input.readStringRequireUtf8();
              bitField0_ |= 0x00000001;
              break;
            } // case 10
            case 18: {
              java.lang.String s = input.readStringRequireUtf8();
              ensureHobbiesIsMutable();
              hobbies_.add(s);
              break;
            } // case 18
            default: {
              if (!super.parseUnknownField(input, extensionRegistry, tag)) {
                done = true; // was an endgroup tag
              }
              break;
            } // default:
          } // switch (tag)
        } // while (!done)
      } catch (com.google.protobuf.InvalidProtocolBufferException e) {
        throw e.unwrapIOException();
      } finally {
        onChanged();
      } // finally
      return this;
    }
    private int bitField0_;

    private java.lang.Object dateOfBirth_ = "";
    /**
     * <code>string date_of_birth = 1;</code>
     * @return The dateOfBirth.
     */
    public java.lang.String getDateOfBirth() {
      java.lang.Object ref = dateOfBirth_;
      if (!(ref instanceof java.lang.String)) {
        com.google.protobuf.ByteString bs =
            (com.google.protobuf.ByteString) ref;
        java.lang.String s = bs.toStringUtf8();
        dateOfBirth_ = s;
        return s;
      } else {
        return (java.lang.String) ref;
      }
    }
    /**
     * <code>string date_of_birth = 1;</code>
     * @return The bytes for dateOfBirth.
     */
    public com.google.protobuf.ByteString
        getDateOfBirthBytes() {
      java.lang.Object ref = dateOfBirth_;
      if (ref instanceof String) {
        com.google.protobuf.ByteString b = 
            com.google.protobuf.ByteString.copyFromUtf8(
                (java.lang.String) ref);
        dateOfBirth_ = b;
        return b;
      } else {
        return (com.google.protobuf.ByteString) ref;
      }
    }
    /**
     * <code>string date_of_birth = 1;</code>
     * @param value The dateOfBirth to set.
     * @return This builder for chaining.
     */
    public Builder setDateOfBirth(
        java.lang.String value) {
      if (value == null) { throw new NullPointerException(); }
      dateOfBirth_ = value;
      bitField0_ |= 0x00000001;
      onChanged();
      return this;
    }
    /**
     * <code>string date_of_birth = 1;</code>
     * @return This builder for chaining.
     */
    public Builder clearDateOfBirth() {
      dateOfBirth_ = getDefaultInstance().getDateOfBirth();
      bitField0_ = (bitField0_ & ~0x00000001);
      onChanged();
      return this;
    }
    /**
     * <code>string date_of_birth = 1;</code>
     * @param value The bytes for dateOfBirth to set.
     * @return This builder for chaining.
     */
    public Builder setDateOfBirthBytes(
        com.google.protobuf.ByteString value) {
      if (value == null) { throw new NullPointerException(); }
      checkByteStringIsUtf8(value);
      dateOfBirth_ = value;
      bitField0_ |= 0x00000001;
      onChanged();
      return this;
    }

    private com.google.protobuf.LazyStringArrayList hobbies_ =
        com.google.protobuf.LazyStringArrayList.emptyList();
    private void ensureHobbiesIsMutable() {
      if (!hobbies_.isModifiable()) {
        hobbies_ = new com.google.protobuf.LazyStringArrayList(hobbies_);
      }
      bitField0_ |= 0x00000002;
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @return A list containing the hobbies.
     */
    public com.google.protobuf.ProtocolStringList
        getHobbiesList() {
      hobbies_.makeImmutable();
      return hobbies_;
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @return The count of hobbies.
     */
    public int getHobbiesCount() {
      return hobbies_.size();
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @param index The index of the element to return.
     * @return The hobbies at the given index.
     */
    public java.lang.String getHobbies(int index) {
      return hobbies_.get(index);
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @param index The index of the value to return.
     * @return The bytes of the hobbies at the given index.
     */
    public com.google.protobuf.ByteString
        getHobbiesBytes(int index) {
      return hobbies_.getByteString(index);
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @param index The index to set the value at.
     * @param value The hobbies to set.
     * @return This builder for chaining.
     */
    public Builder setHobbies(
        int index, java.lang.String value) {
      if (value == null) { throw new NullPointerException(); }
      ensureHobbiesIsMutable();
      hobbies_.set(index, value);
      bitField0_ |= 0x00000002;
      onChanged();
      return this;
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @param value The hobbies to add.
     * @return This builder for chaining.
     */
    public Builder addHobbies(
        java.lang.String value) {
      if (value == null) { throw new NullPointerException(); }
      ensureHobbiesIsMutable();
      hobbies_.add(value);
      bitField0_ |= 0x00000002;
      onChanged();
      return this;
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @param values The hobbies to add.
     * @return This builder for chaining.
     */
    public Builder addAllHobbies(
        java.lang.Iterable<java.lang.String> values) {
      ensureHobbiesIsMutable();
      com.google.protobuf.AbstractMessageLite.Builder.addAll(
          values, hobbies_);
      bitField0_ |= 0x00000002;
      onChanged();
      return this;
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @return This builder for chaining.
     */
    public Builder clearHobbies() {
      hobbies_ =
        com.google.protobuf.LazyStringArrayList.emptyList();
      bitField0_ = (bitField0_ & ~0x00000002);;
      onChanged();
      return this;
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @param value The bytes of the hobbies to add.
     * @return This builder for chaining.
     */
    public Builder addHobbiesBytes(
        com.google.protobuf.ByteString value) {
      if (value == null) { throw new NullPointerException(); }
      checkByteStringIsUtf8(value);
      ensureHobbiesIsMutable();
      hobbies_.add(value);
      bitField0_ |= 0x00000002;
      onChanged();
      return this;
    }

    // @@protoc_insertion_point(builder_scope:example.v1.PersonalProfile)
  }

  // @@protoc_insertion_point(class_scope:example.v1.PersonalProfile)
  private static final com.example.protos.v1.PersonalProfile DEFAULT_INSTANCE;
  static {
    DEFAULT_INSTANCE = new com.example.protos.v1.PersonalProfile();
  }

  public static com.example.protos.v1.PersonalProfile getDefaultInstance() {
    return DEFAULT_INSTANCE;
  }

  private static final com.google.protobuf.Parser<PersonalProfile>
      PARSER = new com.google.protobuf.AbstractParser<PersonalProfile>() {
    @java.lang.Override
    public PersonalProfile parsePartialFrom(
        com.google.protobuf.CodedInputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws com.google.protobuf.InvalidProtocolBufferException {
      Builder builder = newBuilder();
      try {
        builder.mergeFrom(input, extensionRegistry);
      } catch (com.google.protobuf.InvalidProtocolBufferException e) {
        throw e.setUnfinishedMessage(builder.buildPartial());
      } catch (com.google.protobuf.UninitializedMessageException e) {
        throw e.asInvalidProtocolBufferException().setUnfinishedMessage(builder.buildPartial());
      } catch (java.io.IOException e) {
        throw new com.google.protobuf.InvalidProtocolBufferException(e)
            .setUnfinishedMessage(builder.buildPartial());
      }
      return builder.buildPartial();
    }
  };

  public static com.google.protobuf.Parser<PersonalProfile> parser() {
    return PARSER;
  }

  @java.lang.Override
  public com.google.protobuf.Parser<PersonalProfile> getParserForType() {
    return PARSER;
  }

  @java.lang.Override
  public com.example.protos.v1.PersonalProfile getDefaultInstanceForType() {
    return DEFAULT_INSTANCE;
  }

}

