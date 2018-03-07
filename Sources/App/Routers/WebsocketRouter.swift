//
//  WebsocketRouter.swift
//  App
//
//  Created by Niklas Sauer on 25.02.18.
//

import Foundation
import Vapor
import WebSocket
import RoadChatKit

class WebsocketRouter: RouteCollection {
    func boot(router: Router) throws {
        let authMiddleware = User.tokenAuthMiddleware(database: .sqlite)
        let conversationController = ConversationController()
        
        // /chat/Conversation.parameter/live
        router.grouped(authMiddleware).websocket("chat", Conversation.parameter, "live", onUpgrade: conversationController.liveChat)
    }
}

