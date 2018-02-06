//
//  CommunityRouter.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor

class CommunityRouter: RouteCollection {
    func boot(router: Router) throws {
        let communityController = CommunityController()

        // /community/board
        router.get("board", use: communityController.index)

        // /traffic/message
//        router.post("message", use: communityController.create)

        // /traffic/message/TrafficMessage.parameter
//        let message = router.grouped(CommunityMessage.parameter)

//        message.get(use: )
//        message.delete(use: )
//        message.get("upvote", use: )
//        message.get("downvote", use: )
    }
}

