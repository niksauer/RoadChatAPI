// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "RoadChatAPI",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", .exact("3.0.0-beta.3.1.3")),
        .package(url: "https://github.com/vapor/fluent", .exact("3.0.0-beta.3")),
        .package(url: "https://github.com/niksauer/auth", .branch("beta")),
        .package(url: "https://github.com/vapor/jwt", .exact("3.0.0-beta.1.1")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentSQLite", "Authentication", "JWT"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
