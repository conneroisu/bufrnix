// Generated by the protocol buffer compiler. DO NOT EDIT!
// NO CHECKED-IN PROTOBUF GENCODE
// source: example/v1/user.proto

// Generated files should ignore deprecation warnings
@file:Suppress("DEPRECATION")
package com.example.protos.v1;

@kotlin.jvm.JvmName("-initializepersonalProfile")
public inline fun personalProfile(block: com.example.protos.v1.PersonalProfileKt.Dsl.() -> kotlin.Unit): com.example.protos.v1.PersonalProfile =
  com.example.protos.v1.PersonalProfileKt.Dsl._create(com.example.protos.v1.PersonalProfile.newBuilder()).apply { block() }._build()
/**
 * Protobuf type `example.v1.PersonalProfile`
 */
public object PersonalProfileKt {
  @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
  @com.google.protobuf.kotlin.ProtoDslMarker
  public class Dsl private constructor(
    private val _builder: com.example.protos.v1.PersonalProfile.Builder
  ) {
    public companion object {
      @kotlin.jvm.JvmSynthetic
    @kotlin.PublishedApi
      internal fun _create(builder: com.example.protos.v1.PersonalProfile.Builder): Dsl = Dsl(builder)
    }

    @kotlin.jvm.JvmSynthetic
  @kotlin.PublishedApi
    internal fun _build(): com.example.protos.v1.PersonalProfile = _builder.build()

    /**
     * `string date_of_birth = 1;`
     */
    public var dateOfBirth: kotlin.String
      @kotlin.jvm.JvmName("getDateOfBirth")
        get() = _builder.dateOfBirth
      @kotlin.jvm.JvmName("setDateOfBirth")
        set(value) {
        _builder.dateOfBirth = value
      }
    /**
     * <code>string date_of_birth = 1;</code>
     * @return This builder for chaining.
     */
    public fun clearDateOfBirth() {
      _builder.clearDateOfBirth()
    }

    /**
     * An uninstantiable, behaviorless type to represent the field in
     * generics.
     */
    @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
    public class HobbiesProxy private constructor() : com.google.protobuf.kotlin.DslProxy()
    /**
     * <code>repeated string hobbies = 2;</code>
     * @return A list containing the hobbies.
     * @return This builder for chaining.
     */
    public val hobbies: com.google.protobuf.kotlin.DslList<kotlin.String, HobbiesProxy>
    @kotlin.OptIn(com.google.protobuf.kotlin.OnlyForUseByGeneratedProtoCode::class)
      get() = com.google.protobuf.kotlin.DslList(
        _builder.hobbiesList
      )
    /**
     * <code>repeated string hobbies = 2;</code>
     * @param value The hobbies to add.
     * @return This builder for chaining.
     */
    @kotlin.jvm.JvmSynthetic
@kotlin.jvm.JvmName("addHobbies")
    public fun com.google.protobuf.kotlin.DslList<kotlin.String, HobbiesProxy>.add(value: kotlin.String) {
      _builder.addHobbies(value)
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @param value The hobbies to add.
     * @return This builder for chaining.
     */
    @kotlin.jvm.JvmSynthetic
@kotlin.jvm.JvmName("plusAssignHobbies")
    @Suppress("NOTHING_TO_INLINE")
    public inline operator fun com.google.protobuf.kotlin.DslList<kotlin.String, HobbiesProxy>.plusAssign(value: kotlin.String) {
      add(value)
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @param values The hobbies to add.
     * @return This builder for chaining.
     */
    @kotlin.jvm.JvmSynthetic
@kotlin.jvm.JvmName("addAllHobbies")
    public fun com.google.protobuf.kotlin.DslList<kotlin.String, HobbiesProxy>.addAll(values: kotlin.collections.Iterable<kotlin.String>) {
      _builder.addAllHobbies(values)
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @param values The hobbies to add.
     * @return This builder for chaining.
     */
    @kotlin.jvm.JvmSynthetic
@kotlin.jvm.JvmName("plusAssignAllHobbies")
    @Suppress("NOTHING_TO_INLINE")
    public inline operator fun com.google.protobuf.kotlin.DslList<kotlin.String, HobbiesProxy>.plusAssign(values: kotlin.collections.Iterable<kotlin.String>) {
      addAll(values)
    }
    /**
     * <code>repeated string hobbies = 2;</code>
     * @param index The index to set the value at.
     * @param value The hobbies to set.
     * @return This builder for chaining.
     */
    @kotlin.jvm.JvmSynthetic
@kotlin.jvm.JvmName("setHobbies")
    public operator fun com.google.protobuf.kotlin.DslList<kotlin.String, HobbiesProxy>.set(index: kotlin.Int, value: kotlin.String) {
      _builder.setHobbies(index, value)
    }/**
     * <code>repeated string hobbies = 2;</code>
     * @return This builder for chaining.
     */
    @kotlin.jvm.JvmSynthetic
@kotlin.jvm.JvmName("setHobbies")
    public fun com.google.protobuf.kotlin.DslList<kotlin.String, HobbiesProxy>.clear() {
      _builder.clearHobbies()
    }}
}
@kotlin.jvm.JvmSynthetic
public inline fun com.example.protos.v1.PersonalProfile.copy(block: `com.example.protos.v1`.PersonalProfileKt.Dsl.() -> kotlin.Unit): com.example.protos.v1.PersonalProfile =
  `com.example.protos.v1`.PersonalProfileKt.Dsl._create(this.toBuilder()).apply { block() }._build()

