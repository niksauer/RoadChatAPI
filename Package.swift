// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "RoadChatAPI",
    dependencies: [
        .package(url: "https://github.com/niksauer/vapor", .exact("3.0.0-beta.3.1")),
        .package(url: "https://github.com/niksauer/fluent", .exact("3.0.0-beta.2.1")),
        .package(url: "https://github.com/niksauer/auth", .branch("beta")),
        .package(url: "https://github.com/vapor/validation", .exact("2.0.0-beta.1.1")),
        .package(url: "https://github.com/vapor/jwt", .exact("3.0.0-beta.1.1")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentSQLite", "Authentication", "Validation", "JWT"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
