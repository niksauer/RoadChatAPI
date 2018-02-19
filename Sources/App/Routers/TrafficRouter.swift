//
//  TrafficRouter.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor

class TrafficRouter: RouteCollection {
    func boot(router: Router) throws {
        let trafficController = TrafficController()
        
        let trafficMessageBoard = router.grouped("board")
        let trafficMessage = router.grouped("message").grouped(TrafficMessage.parameter)
        let authenticatedTrafficMessage = trafficMessage.grouped(try User.tokenAuthMiddleware())
        
        // /traffic/board
        trafficMessageBoard.get(use: trafficController.index)
        trafficMessageBoard.grouped(try User.tokenAuthMiddleware()).post(use: trafficController.create)
        
        // /traffic/messages/TrafficMessage.parameter
        trafficMessage.get(use: trafficController.get)
        authenticatedTrafficMessage.delete(use: trafficController.delete)
        authenticatedTrafficMessage.get("upvote", use: trafficController.upvote)
        authenticatedTrafficMessage.get("downvote", use: trafficController.downvote)
    }
}
