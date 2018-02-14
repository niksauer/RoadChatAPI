// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "RoadChatAPI",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .exact("3.0.0-beta.3")),
        .package(url: "https://github.com/vapor/fluent.git", .exact("3.0.0-beta.2")),
        .package(url: "https://github.com/vapor/auth.git", .exact("2.0.0-beta.2")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentSQLite", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
