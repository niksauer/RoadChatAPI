//
//  ConversationRequest.swift
//  App
//
//  Created by Niklas Sauer on 18.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension ConversationRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<ConversationRequest> {
        var validations = Validations(ConversationRequest.self)
        try validations.add(\.title, .count(1...50))
        return validations
    }
}

//extension ConversationRequest: OptionallyValidatable {
//    static var optionalValidations: OptionallyValidatable.Validations = [:]
//}

extension ConversationRequest: Payload {
    typealias RequestType = ConversationRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("title", String.self),
        ("participants", [Int].self),
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
