module github.com/example/proto

go 1.21

require (
	google.golang.org/protobuf v1.34.0
	github.com/example/struct-transformer-example v0.0.0
)

replace github.com/example/struct-transformer-example => ../..
