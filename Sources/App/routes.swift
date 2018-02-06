import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    try router.grouped("community").register(collection: CommunityRouter())
    try router.grouped("traffic").register(collection: TrafficRouter())
    try router.grouped("user").register(collection: UserRouter())
//    try router.grouped("car").register(collection: CarRouter())
}
