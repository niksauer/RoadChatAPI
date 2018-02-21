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
        let communityMessageBoard = router.grouped("board")
       
        
        // /community/board
        communityMessageBoard.get(use: communityController.index)
        communityMessageBoard.grouped(try User.tokenAuthMiddleware()).post(use: communityController.create)
        
        // /community/message/communityMessage.parameter
        let communityMessage = router.grouped("message").grouped(CommunityMessage.parameter)
        let authenticatedCommunityMessage = communityMessage.grouped(try User.tokenAuthMiddleware())
        
        communityMessage.get(use: communityController.get)
        authenticatedCommunityMessage.delete(use: communityController.delete)

        // /community/messages/CommunityMessage.parameter/upvote
        authenticatedCommunityMessage.get("upvote", use: communityController.upvote)
        
        // /community/messages/CommunityMessage.parameter/downvote
        authenticatedCommunityMessage.get("downvote", use: communityController.downvote)
    }
}

