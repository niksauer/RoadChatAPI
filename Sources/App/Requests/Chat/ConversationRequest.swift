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
        try validations.add(\.recipients, .count(1...))
        return validations
    }
}

//extension ConversationRequest: OptionallyValidatable {
//    static func optionalValidations() throws -> Validations<ConversationRequest> {
//        let validations = Validations(ConversationRequest.self)
//        try validations.add(\.title, .count(1...50))
//        return validations
//    }
//}

extension ConversationRequest: Payload {
    static var requiredParameters: [Payload.Parameter] = [
        ("recipients", [Int].self),
    ]
    
    static var optionalParameters: [Payload.Parameter] = [
//        ("title", String.self),
    ]
}

extension ConversationUpdateRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<ConversationUpdateRequest> {
        let validations = Validations(ConversationUpdateRequest.self)
        return validations
    }
}

extension ConversationUpdateRequest: Payload {
    static var requiredParameters: [Payload.Parameter] = [
    
    ]
    
    static var optionalParameters: [Payload.Parameter] = [
    
    ]
}
