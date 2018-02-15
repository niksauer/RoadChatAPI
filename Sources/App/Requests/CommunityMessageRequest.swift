//
//  CommunityMessageRequest.swift
//  App
//
//  Created by Niklas Sauer on 08.02.18.
//

import Foundation
import Vapor
import Validation

struct CommunityMessageRequest: Codable {
    let senderID: Int
    let time: Date
    let location: String
    let message: String
}

extension CommunityMessageRequest: Validatable {
    static var validations: Validations = [
//        key(\CommunityMessageRequest.senderID): IsInt(),
//        key(\CommunityMessageRequest.time): IsDate(),
        key(\CommunityMessageRequest.location): IsAlphanumeric(),
        key(\CommunityMessageRequest.message): IsCount(0...280),
    ]
}

extension CommunityMessageRequest: RequestBody {
    typealias RequestType = CommunityMessageRequest
    
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] = [
        ("senderID", 1),
        ("time", Date()),
        ("location", "a22exF"),
        ("message", "Stau auf der A3"),
    ]
}
