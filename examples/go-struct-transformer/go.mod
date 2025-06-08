module github.com/conneroisu/bufrnix/examples/go-struct-transformer

go 1.22

toolchain go1.23.8

require github.com/example/proto v0.0.0-00010101000000-000000000000

require (
	github.com/bold-commerce/protoc-gen-struct-transformer v1.0.8 // indirect
	github.com/gogo/protobuf v1.3.2 // indirect
	google.golang.org/protobuf v1.36.6 // indirect
)

replace github.com/example/proto => ./gen/go
