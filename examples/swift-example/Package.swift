// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "SwiftExample",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.29.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftExample",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ],
            path: "Sources/SwiftExample"
        ),
    ]
)