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
        let trafficMessage = router.grouped("messages").grouped(TrafficMessage.parameter)
        
        // /traffic/board
        trafficMessageBoard.get(use: trafficController.index)
        trafficMessageBoard.grouped(try User.tokenAuthMiddleware()).post(use: trafficController.create)
        
        // /traffic/messages/TrafficMessage.parameter
        trafficMessage.get(use: trafficController.get)
//      trafficMessage.delete(use: trafficController.delete)
//      trafficMessage.put("upvote", use: trafficController.upvote)
//      trafficMessage.put("downvote", use: trafficController.downvote)
    }
}
