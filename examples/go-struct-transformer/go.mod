module github.com/example/struct-transformer-example

go 1.21

require github.com/example/proto v0.0.0-00010101000000-000000000000

require (
	github.com/bold-commerce/protoc-gen-struct-transformer v1.0.8 // indirect
	github.com/gogo/protobuf v1.3.1 // indirect
	google.golang.org/protobuf v1.34.0 // indirect
)

replace github.com/example/proto => ./gen/go
