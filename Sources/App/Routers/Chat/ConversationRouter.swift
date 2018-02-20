//
//  ConversationRouter.swift
//  App
//
//  Created by Niklas Sauer on 19.02.18.
//

import Foundation
import Vapor

class ConversationRouter: RouteCollection {
    func boot(router: Router) throws {
        let conversationController = ConversationController()
        
        // /chat
        router.grouped(try User.tokenAuthMiddleware()).post(use: conversationController.create)
        
        // /chat/Conversation.parameter
        let conversation = router.grouped(Conversation.parameter)
        let authenticatedConversation = conversation.grouped(try User.tokenAuthMiddleware())
        
        authenticatedConversation.get(use: conversationController.get)
        authenticatedConversation.delete(use: conversationController.delete)
        
        // /chat/Conversation.parameter/messages
        authenticatedConversation.group("messages", use: { group in
            group.get(use: conversationController.getMessages)
            group.post(use: conversationController.createMessage)
        })
        
        // /chat/Conversation.parameter/participants
        authenticatedConversation.group("participants", use: { group in
            group.get(use: conversationController.getParticipants)
        })
    }
}
