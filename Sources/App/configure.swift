import Foundation
import Vapor
import FluentSQLite
import Authentication

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(AuthenticationProvider())

    // Configure a SQLite database
    var databases = DatabaseConfig()
    try databases.add(database: SQLiteDatabase(storage: .memory), as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: Token.self, database: .sqlite)
    migrations.add(model: Settings.self, database: .sqlite)
    migrations.add(model: Privacy.self, database: .sqlite)
    migrations.add(model: Profile.self, database: .sqlite)
    migrations.add(model: Car.self, database: .sqlite)
    migrations.add(model: TrafficMessage.self, database: .sqlite)
    migrations.add(model: TrafficKarma.self, database: .sqlite)
    migrations.add(model: CommunityMessage.self, database: .sqlite)
    
    migrations.add(model: Conversation.self, database: .sqlite)
    migrations.add(model: DirectMessage.self, database: .sqlite)
    migrations.add(model: IsParticipant.self, database: .sqlite)
    services.register(migrations)
    
    // Configure middleware
//    let middleware = MiddlewareConfig.default()
//    services.register(middleware)
}
