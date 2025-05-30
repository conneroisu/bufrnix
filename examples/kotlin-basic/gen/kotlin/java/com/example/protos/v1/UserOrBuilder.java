// Generated by the protocol buffer compiler.  DO NOT EDIT!
// NO CHECKED-IN PROTOBUF GENCODE
// source: example/v1/user.proto
// Protobuf Java Version: 4.30.2

package com.example.protos.v1;

public interface UserOrBuilder extends
    // @@protoc_insertion_point(interface_extends:example.v1.User)
    com.google.protobuf.MessageOrBuilder {

  /**
   * <code>string id = 1;</code>
   * @return The id.
   */
  java.lang.String getId();
  /**
   * <code>string id = 1;</code>
   * @return The bytes for id.
   */
  com.google.protobuf.ByteString
      getIdBytes();

  /**
   * <code>string name = 2;</code>
   * @return The name.
   */
  java.lang.String getName();
  /**
   * <code>string name = 2;</code>
   * @return The bytes for name.
   */
  com.google.protobuf.ByteString
      getNameBytes();

  /**
   * <code>string email = 3;</code>
   * @return The email.
   */
  java.lang.String getEmail();
  /**
   * <code>string email = 3;</code>
   * @return The bytes for email.
   */
  com.google.protobuf.ByteString
      getEmailBytes();

  /**
   * <code>repeated .example.v1.Address addresses = 4;</code>
   */
  java.util.List<com.example.protos.v1.Address> 
      getAddressesList();
  /**
   * <code>repeated .example.v1.Address addresses = 4;</code>
   */
  com.example.protos.v1.Address getAddresses(int index);
  /**
   * <code>repeated .example.v1.Address addresses = 4;</code>
   */
  int getAddressesCount();
  /**
   * <code>repeated .example.v1.Address addresses = 4;</code>
   */
  java.util.List<? extends com.example.protos.v1.AddressOrBuilder> 
      getAddressesOrBuilderList();
  /**
   * <code>repeated .example.v1.Address addresses = 4;</code>
   */
  com.example.protos.v1.AddressOrBuilder getAddressesOrBuilder(
      int index);

  /**
   * <code>.example.v1.User.Status status = 5;</code>
   * @return The enum numeric value on the wire for status.
   */
  int getStatusValue();
  /**
   * <code>.example.v1.User.Status status = 5;</code>
   * @return The status.
   */
  com.example.protos.v1.User.Status getStatus();

  /**
   * <code>.example.v1.PersonalProfile personal = 6;</code>
   * @return Whether the personal field is set.
   */
  boolean hasPersonal();
  /**
   * <code>.example.v1.PersonalProfile personal = 6;</code>
   * @return The personal.
   */
  com.example.protos.v1.PersonalProfile getPersonal();
  /**
   * <code>.example.v1.PersonalProfile personal = 6;</code>
   */
  com.example.protos.v1.PersonalProfileOrBuilder getPersonalOrBuilder();

  /**
   * <code>.example.v1.BusinessProfile business = 7;</code>
   * @return Whether the business field is set.
   */
  boolean hasBusiness();
  /**
   * <code>.example.v1.BusinessProfile business = 7;</code>
   * @return The business.
   */
  com.example.protos.v1.BusinessProfile getBusiness();
  /**
   * <code>.example.v1.BusinessProfile business = 7;</code>
   */
  com.example.protos.v1.BusinessProfileOrBuilder getBusinessOrBuilder();

  com.example.protos.v1.User.ProfileCase getProfileCase();
}
