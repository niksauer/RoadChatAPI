//
//  Chatroom.swift
//  App
//
//  Created by Niklas Sauer on 20.02.18.
//

import Foundation
import Vapor
import WebSocket

class Chatroom {
    let conversationID: Int
    var connections: [Int: WebSocket] = [:]
    
    init(conversationID: Int) {
        self.conversationID = conversationID
    }
    
    enum Notification {
        case online(userID: Int)
        case offline(userID: Int)
        case custom(message: String)
    }
    
    func notify(event: Notification) {
        switch event {
        case .online(let userID):
            send(senderID: 0, message: "User '\(userID)' is online now.", exclude: [userID])
        case .offline(let userID):
            send(senderID: 0, message: "User '\(userID)' is offline now.", exclude: [userID])
        case .custom(let message):
            send(senderID: 0, message: message)
        }
    }
    
    func send(senderID: Int, message: String) {
        send(senderID: senderID, message: message, exclude: [])
    }
    
    private func send(senderID: Int, message: String, receipientID: Int) {
        guard let websocket = connections[receipientID] else {
            // receipient is not online
            return
        }
        
        websocket.send(message)
    }
    
    private func send(senderID: Int, message: String, exclude: [Int]) {
        for (receipientID, websocket) in connections {
            guard senderID != receipientID && !exclude.contains(where: { $0 == receipientID }) else {
                continue
            }
            
            websocket.send(message)
        }
    }
}

extension WebSocket {
    enum Notification {
        case existingSession
    }
    
    func notify(event: Notification) {
        switch event {
        case .existingSession:
            self.send("You already have an active session. Redirecting messages here.")
        }
    }
}
