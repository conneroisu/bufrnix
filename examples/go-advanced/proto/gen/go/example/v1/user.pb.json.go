// Code generated by protoc-gen-go-json. DO NOT EDIT.
// source: example/v1/user.proto

package examplev1

import (
	"google.golang.org/protobuf/encoding/protojson"
)

// MarshalJSON implements json.Marshaler
func (msg *User) MarshalJSON() ([]byte, error) {
	return protojson.MarshalOptions{
		UseProtoNames: true,
	}.Marshal(msg)
}

// UnmarshalJSON implements json.Unmarshaler
func (msg *User) UnmarshalJSON(b []byte) error {
	return protojson.UnmarshalOptions{}.Unmarshal(b, msg)
}

// MarshalJSON implements json.Marshaler
func (msg *User_Profile) MarshalJSON() ([]byte, error) {
	return protojson.MarshalOptions{
		UseProtoNames: true,
	}.Marshal(msg)
}

// UnmarshalJSON implements json.Unmarshaler
func (msg *User_Profile) UnmarshalJSON(b []byte) error {
	return protojson.UnmarshalOptions{}.Unmarshal(b, msg)
}

// MarshalJSON implements json.Marshaler
func (msg *GetUserRequest) MarshalJSON() ([]byte, error) {
	return protojson.MarshalOptions{
		UseProtoNames: true,
	}.Marshal(msg)
}

// UnmarshalJSON implements json.Unmarshaler
func (msg *GetUserRequest) UnmarshalJSON(b []byte) error {
	return protojson.UnmarshalOptions{}.Unmarshal(b, msg)
}

// MarshalJSON implements json.Marshaler
func (msg *GetUserResponse) MarshalJSON() ([]byte, error) {
	return protojson.MarshalOptions{
		UseProtoNames: true,
	}.Marshal(msg)
}

// UnmarshalJSON implements json.Unmarshaler
func (msg *GetUserResponse) UnmarshalJSON(b []byte) error {
	return protojson.UnmarshalOptions{}.Unmarshal(b, msg)
}

// MarshalJSON implements json.Marshaler
func (msg *ListUsersRequest) MarshalJSON() ([]byte, error) {
	return protojson.MarshalOptions{
		UseProtoNames: true,
	}.Marshal(msg)
}

// UnmarshalJSON implements json.Unmarshaler
func (msg *ListUsersRequest) UnmarshalJSON(b []byte) error {
	return protojson.UnmarshalOptions{}.Unmarshal(b, msg)
}

// MarshalJSON implements json.Marshaler
func (msg *ListUsersResponse) MarshalJSON() ([]byte, error) {
	return protojson.MarshalOptions{
		UseProtoNames: true,
	}.Marshal(msg)
}

// UnmarshalJSON implements json.Unmarshaler
func (msg *ListUsersResponse) UnmarshalJSON(b []byte) error {
	return protojson.UnmarshalOptions{}.Unmarshal(b, msg)
}

// MarshalJSON implements json.Marshaler
func (msg *CreateUserRequest) MarshalJSON() ([]byte, error) {
	return protojson.MarshalOptions{
		UseProtoNames: true,
	}.Marshal(msg)
}

// UnmarshalJSON implements json.Unmarshaler
func (msg *CreateUserRequest) UnmarshalJSON(b []byte) error {
	return protojson.UnmarshalOptions{}.Unmarshal(b, msg)
}

// MarshalJSON implements json.Marshaler
func (msg *CreateUserResponse) MarshalJSON() ([]byte, error) {
	return protojson.MarshalOptions{
		UseProtoNames: true,
	}.Marshal(msg)
}

// UnmarshalJSON implements json.Unmarshaler
func (msg *CreateUserResponse) UnmarshalJSON(b []byte) error {
	return protojson.UnmarshalOptions{}.Unmarshal(b, msg)
}

// MarshalJSON implements json.Marshaler
func (msg *UpdateUserRequest) MarshalJSON() ([]byte, error) {
	return protojson.MarshalOptions{
		UseProtoNames: true,
	}.Marshal(msg)
}

// UnmarshalJSON implements json.Unmarshaler
func (msg *UpdateUserRequest) UnmarshalJSON(b []byte) error {
	return protojson.UnmarshalOptions{}.Unmarshal(b, msg)
}

// MarshalJSON implements json.Marshaler
func (msg *UpdateUserResponse) MarshalJSON() ([]byte, error) {
	return protojson.MarshalOptions{
		UseProtoNames: true,
	}.Marshal(msg)
}

// UnmarshalJSON implements json.Unmarshaler
func (msg *UpdateUserResponse) UnmarshalJSON(b []byte) error {
	return protojson.UnmarshalOptions{}.Unmarshal(b, msg)
}
