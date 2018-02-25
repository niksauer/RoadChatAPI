//
//  ConversationRouter.swift
//  App
//
//  Created by Niklas Sauer on 19.02.18.
//

import Foundation
import Vapor
import WebSocket

class ConversationRouter: RouteCollection {
    func boot(router: Router) throws {
        let authMiddleware = try User.tokenAuthMiddleware(database: .sqlite)
        let conversationController = ConversationController()
        
        // /chat
        router.grouped(authMiddleware).post(use: conversationController.create)
   
        // /chat/Conversation.parameter
        let conversation = router.grouped(Conversation.parameter)
        let authenticatedConversation = conversation.grouped(authMiddleware)
        
        authenticatedConversation.get(use: conversationController.get)
        authenticatedConversation.delete(use: conversationController.delete)
        
        // /chat/Conversation.parameter/live
        authenticatedConversation.websocket("live", onUpgrade: conversationController.liveChat)
        
        // /chat/Conversation.parameter/messages
        authenticatedConversation.group("messages", configure: { group in
            group.get(use: conversationController.getMessages)
            group.post(use: conversationController.createMessage)
        })
        
        // /chat/Conversation.parameter/participants
        authenticatedConversation.group("participants", configure: { group in
            group.get(use: conversationController.getParticipants)
        })
        
        // /chat/Conversation.parameter/approve
        authenticatedConversation.get("accept", use: conversationController.acceptConversation)
        
        // /chat/Conversation.parameter/deny
        authenticatedConversation.get("deny", use: conversationController.denyConversation)
    }
}
