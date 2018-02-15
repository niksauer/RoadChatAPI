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
        
        let trafficMessage = router.grouped(TrafficMessage.parameter)
        let authenticatedTrafficMessage = trafficMessage.grouped(try User.tokenAuthMiddleware())
        
        // /traffic/board
        trafficMessage.get(use: trafficController.index)
        authenticatedTrafficMessage.post(use: trafficController.create)
        
        // /traffic/message/TrafficMessage.parameter
//        let message = router.grouped(TrafficMessage.parameter)
        
//        message.get(use: )
//        message.delete(use: )
//        message.get("upvote", use: )
//        message.get("downvote", use: )
    }
}
