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

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
//    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
//    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
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
    migrations.add(model: Location.self, database: .sqlite)
    
    migrations.add(model: TrafficMessage.self, database: .sqlite)
    migrations.add(model: TrafficKarmaDonation.self, database: .sqlite)
    migrations.add(model: Validation.self, database: .sqlite)
    
    migrations.add(model: CommunityMessage.self, database: .sqlite)
    migrations.add(model: CommunityKarmaDonation.self, database: .sqlite)
    
    migrations.add(model: Conversation.self, database: .sqlite)
    migrations.add(model: DirectMessage.self, database: .sqlite)
    migrations.add(model: Participation.self, database: .sqlite)
    
    services.register(migrations)
}
