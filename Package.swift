// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "RoadChatAPI",
    dependencies: [
        // 💧 A server-side Swift web framework. 
        .package(url: "https://github.com/vapor/vapor.git", .branch("beta")),

        // 🖋 Swift ORM framework (queries, models, and relations) for building NoSQL and SQL database integrations.
        .package(url: "https://github.com/vapor/fluent.git", .branch("beta")),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

