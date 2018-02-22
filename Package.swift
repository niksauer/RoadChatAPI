// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "RoadChatAPI",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", .exact("3.0.0-beta.3.1.3")),
        .package(url: "https://github.com/vapor/fluent", .exact("3.0.0-beta.3")),
        .package(url: "https://github.com/niksauer/auth", .branch("beta")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentSQLite", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
