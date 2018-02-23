import Foundation
import Vapor
import FluentMySQL
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
    try services.register(FluentMySQLProvider())
    try services.register(AuthenticationProvider())

    // Configure a MySQL database
    var databases = DatabaseConfig()
    databases.add(database: MySQLDatabase(hostname: "localhost", user: "swift", password: "swift", database: "roadchat"), as: .mysql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    
    migrations.add(model: User.self, database: .mysql)

    migrations.add(model: Token.self, database: .mysql)
    migrations.add(model: Settings.self, database: .mysql)
    migrations.add(model: Privacy.self, database: .mysql)
    migrations.add(model: Profile.self, database: .mysql)
    migrations.add(model: Car.self, database: .mysql)
    migrations.add(model: Location.self, database: .mysql)
    
    migrations.add(model: TrafficMessage.self, database: .mysql)
    migrations.add(model: TrafficKarmaDonation.self, database: .mysql)
    migrations.add(model: Validation.self, database: .mysql)
    
    migrations.add(model: CommunityMessage.self, database: .mysql)
    migrations.add(model: CommunityKarmaDonation.self, database: .mysql)
    
    migrations.add(model: Conversation.self, database: .mysql)
    migrations.add(model: DirectMessage.self, database: .mysql)
    migrations.add(model: Participation.self, database: .mysql)
    
    services.register(migrations)
}
