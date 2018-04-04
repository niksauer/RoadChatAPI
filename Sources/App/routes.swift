//
//  routes.swift
//  App
//
//  Created by Niklas Sauer on 24.02.18.
//

import Foundation
import Routing
import Vapor
import WebSocket

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let jsendRouter = router
//    let jsendRouter = router.grouped(JSendMiddleware())
    try jsendRouter.grouped("user").register(collection: UserRouter())
    try jsendRouter.grouped("car").register(collection: CarRouter())
    try jsendRouter.grouped("traffic").register(collection: TrafficRouter())
    try jsendRouter.grouped("community").register(collection: CommunityRouter())
    try jsendRouter.grouped("chat").register(collection: ConversationRouter())

    try router.register(collection: WebsocketRouter())
}
