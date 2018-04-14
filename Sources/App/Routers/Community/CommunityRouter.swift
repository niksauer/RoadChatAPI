//
//  CommunityRouter.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor
import RoadChatKit

class CommunityRouter: RouteCollection {
    func boot(router: Router) throws {
        let authMiddleware = User.tokenAuthMiddleware(database: .mysql)
        let communityController = CommunityController()

        // /community/board
        let communityBoard = router.grouped("board")
        let authenticatedCommunityBoard = communityBoard.grouped(authMiddleware)
        
        authenticatedCommunityBoard.get(use: communityController.index)
        authenticatedCommunityBoard.grouped(authMiddleware).post(use: communityController.create)
        
        // /community/message/communityMessage.parameter
        let communityMessage = router.grouped("message").grouped(CommunityMessage.parameter)
        let authenticatedCommunityMessage = communityMessage.grouped(authMiddleware)
        
        authenticatedCommunityMessage.get(use: communityController.get)
        authenticatedCommunityMessage.delete(use: communityController.delete)

        // /community/messages/CommunityMessage.parameter/upvote
        authenticatedCommunityMessage.get("upvote", use: communityController.upvote)
        
        // /community/messages/CommunityMessage.parameter/downvote
        authenticatedCommunityMessage.get("downvote", use: communityController.downvote)
    }
}

