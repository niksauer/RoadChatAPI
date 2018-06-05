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
    let router = router.grouped(JSendMiddleware())
    
    let rootDirectory = DirectoryConfig.detect().workDir
    let userUploadDirectory = URL(fileURLWithPath: "\(rootDirectory)Public/users")
    let carUploadDirectory = URL(fileURLWithPath: "\(rootDirectory)Public/cars")
    
    try router.grouped("user").register(collection: UserRouter(uploadDirectory: userUploadDirectory))
    try router.grouped("car").register(collection: CarRouter(uploadDirectory: carUploadDirectory))
    try router.grouped("traffic").register(collection: TrafficRouter())
    try router.grouped("community").register(collection: CommunityRouter())
    try router.grouped("chat").register(collection: ConversationRouter())
}
