// Generated by the protocol buffer compiler. DO NOT EDIT!
// NO CHECKED-IN PROTOBUF GENCODE
// source: example/v1/user.proto

// Generated files should ignore deprecation warnings
@file:Suppress("DEPRECATION")
package com.example.protos.v1;

@kotlin.jvm.JvmName("-initializeaddress")
public inline fun address(block: com.example.protos.v1.AddressKt.Dsl.() -> kotlin.Unit): com.example.protos.v1.Address =
  com.example.protos.v1.AddressKt.Dsl._create(com.example.protos.v1.Address.newBuilder()).apply { block() }._build()
/**
 * Protobuf type `example.v1.Address`
 */
public object AddressKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  public class Dsl private constructor(
    private val _builder: com.example.protos.v1.Address.Builder
  ) {
    public companion object {
      @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
      internal fun _create(builder: com.example.protos.v1.Address.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
  @kotlin.PublishedApi
    internal fun _build(): com.example.protos.v1.Address = _builder.build()

    /**
     * `string street = 1;`
     */
    public var street: kotlin.String
      @kotlin.jvm.JvmName("getStreet")
        get() = _builder.street
      @kotlin.jvm.JvmName("setStreet")
        set(value) {
        _builder.street = value
      }
    /**
     * <code>string street = 1;</code>
     * @return This builder for chaining.
     */
    public fun clearStreet() {
      _builder.clearStreet()
    }

    /**
     * `string city = 2;`
     */
    public var city: kotlin.String
      @kotlin.jvm.JvmName("getCity")
        get() = _builder.city
      @kotlin.jvm.JvmName("setCity")
        set(value) {
        _builder.city = value
      }
    /**
     * <code>string city = 2;</code>
     * @return This builder for chaining.
     */
    public fun clearCity() {
      _builder.clearCity()
    }

    /**
     * `string state = 3;`
     */
    public var state: kotlin.String
      @kotlin.jvm.JvmName("getState")
        get() = _builder.state
      @kotlin.jvm.JvmName("setState")
        set(value) {
        _builder.state = value
      }
    /**
     * <code>string state = 3;</code>
     * @return This builder for chaining.
     */
    public fun clearState() {
      _builder.clearState()
    }

    /**
     * `string zip_code = 4;`
     */
    public var zipCode: kotlin.String
      @kotlin.jvm.JvmName("getZipCode")
        get() = _builder.zipCode
      @kotlin.jvm.JvmName("setZipCode")
        set(value) {
        _builder.zipCode = value
      }
    /**
     * <code>string zip_code = 4;</code>
     * @return This builder for chaining.
     */
    public fun clearZipCode() {
      _builder.clearZipCode()
    }

    /**
     * `string country = 5;`
     */
    public var country: kotlin.String
      @kotlin.jvm.JvmName("getCountry")
        get() = _builder.country
      @kotlin.jvm.JvmName("setCountry")
        set(value) {
        _builder.country = value
      }
    /**
     * <code>string country = 5;</code>
     * @return This builder for chaining.
     */
    public fun clearCountry() {
      _builder.clearCountry()
    }
  }
}
@kotlin.jvm.JvmSynthetic
public inline fun com.example.protos.v1.Address.copy(block: `com.example.protos.v1`.AddressKt.Dsl.() -> kotlin.Unit): com.example.protos.v1.Address =
  `com.example.protos.v1`.AddressKt.Dsl._create(this.toBuilder()).apply { block() }._build()

