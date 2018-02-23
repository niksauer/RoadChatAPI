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
    let time: Date
    let location: String
    let message: String
}

extension CommunityMessageRequest: Validatable {
    static var validations: Validations = [
        key(\CommunityMessageRequest.location): IsAlphanumeric(),
        key(\CommunityMessageRequest.message): IsCount(0...255),
    ]
}

extension CommunityMessageRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [:]
}

extension CommunityMessageRequest: Payload {
    typealias RequestType = CommunityMessageRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("time", Date()),
        ("location", "a22exF"),
        ("message", "Stau auf der A3"),
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
