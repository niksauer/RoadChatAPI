//
//  ConversationRequest.swift
//  App
//
//  Created by Niklas Sauer on 18.02.18.
//

import Foundation
import Vapor
import Validation

struct ConversationRequest: Codable {
    let title: String
    let participants: [Int]
}

extension ConversationRequest: Validatable {
    static var validations: Validations = [
        key(\ConversationRequest.title): IsCount(1...50),
    ]
}

extension ConversationRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [:]
}

extension ConversationRequest: Payload {
    typealias RequestType = ConversationRequest
    
    static var requiredParameters: Parameters = [
        ("title", "CryptoBros"),
        ("participants", [0,1]),
    ]
    
    static var optionalParameters: Parameters = []
}
