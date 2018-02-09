import Routing
import Vapor

/// Called after your application has initialized.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#bootswift)
public func boot(_ app: Application) throws {
    let router = try app.make(Router.self).grouped(JSendMiddleware())
    
    try router.grouped("community").register(collection: CommunityRouter())
    try router.grouped("traffic").register(collection: TrafficRouter())
    try router.grouped("user").register(collection: UserRouter())
    try router.grouped("car").register(collection: CarRouter())
}
