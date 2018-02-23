// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "RoadChatAPI",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", .exact("3.0.0-rc.1")),
        .package(url: "https://github.com/vapor/fluent", .branch("master")),
        .package(url: "https://github.com/niksauer/auth", .branch("beta")),
        .package(url: "https://github.com/niksauer/GeoSwift", .branch("master")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentSQLite", "Authentication", "GeoSwift"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
