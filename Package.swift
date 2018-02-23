// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "RoadChatAPI",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", .exact("3.0.0-beta.3.1.3")),
        .package(url: "https://github.com/vapor/fluent", .exact("3.0.0-beta.3")),
        .package(url: "https://github.com/vapor/auth", .revision("3b2a5d8980e24089b250a46e1cca11c9951747b6")),
        .package(url: "https://github.com/niksauer/GeoSwift", .branch("master")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentSQLite", "Authentication", "GeoSwift"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
