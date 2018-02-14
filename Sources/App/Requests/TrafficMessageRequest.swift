//
//  TrafficMessageRequest.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor

struct TrafficMessageRequest: Codable, Validatable {
    let senderID: Int
    let time: Date
    let location: String
    let direction: String
    let note: String?
    
    // Validatable
    typealias RequestType = TrafficMessageRequest
    
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] = [
        ("senderID", 1),
        ("time", Date()),
        ("location", "a22exF"),
        ("direction", "North"),
    ]
}
