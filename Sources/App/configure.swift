import Vapor
import FluentMySQL
import Authentication
import RoadChatKit

let hashingCost: Int = 6 // default = 12

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

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Register middleware
    let middlewares = MiddlewareConfig() // Create empty middleware config
//    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
//    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a MySQL database
    var databases = DatabasesConfig()
    let mySQLConfig = MySQLDatabaseConfig(hostname: "localhost", port: 3306, username: "swift", password: "swift", database: "roadchat")
    let mySQLDatabase = MySQLDatabase(config: mySQLConfig)
    databases.add(database: mySQLDatabase, as: .mysql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()

    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: BearerToken.self, database: .mysql)
    migrations.add(model: Settings.self, database: .mysql)
    migrations.add(model: Privacy.self, database: .mysql)
    migrations.add(model: Profile.self, database: .mysql)
    migrations.add(model: Car.self, database: .mysql)
    migrations.add(model: Location.self, database: .mysql)
    
    migrations.add(model: TrafficMessage.self, database: .mysql)
    migrations.add(model: TrafficMessageKarmaDonation.self, database: .mysql)
    migrations.add(model: TrafficMessageValidation.self, database: .mysql)
    
    migrations.add(model: CommunityMessage.self, database: .mysql)
    migrations.add(model: CommunityMessageKarmaDonation.self, database: .mysql)
    
    migrations.add(model: Conversation.self, database: .mysql)
    migrations.add(model: DirectMessage.self, database: .mysql)
    migrations.add(model: Participation.self, database: .mysql)
    
    services.register(migrations)
    
//    configureWebsockets(&services)
}

//func configureWebsockets(_ services: inout Services) {
//    let websockets = EngineWebSocketServer.default()
//    let _ = User.tokenAuthMiddleware(database: .mysql)
//    let conversationController = ConversationController()
//    
//    websockets.get("chat", Conversation.parameter, "live", use: conversationController.liveChat)
//    
//    services.register(websockets, as: WebSocketServer.self)
//}
