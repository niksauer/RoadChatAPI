// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "RoadChatAPI",
    dependencies: [
        .package(url: "https://github.com/vapor/jwt", .exact("3.0.0-beta.1.1")),
        .package(url: "https://github.com/vapor/vapor", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-mysql", from: "3.0.0-rc.1"),
        .package(url: "https://github.com/vapor/auth", from: "2.0.0-rc.1"),
        .package(url: "https://github.com/petrpavlik/GeoSwift", .exact("1.0.4")),
        .package(url: "https://github.com/niksauer/RoadChatKit", .branch("master")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentMySQL", "Authentication", "JWT", "GeoSwift", "RoadChatKit"]),
        .target(name: "Run", dependencies: ["App"]),
    ]
)
