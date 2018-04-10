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
    public static var validations: Validations = [
        key(\.title): IsCount(1...50),
    ]
}

extension ConversationRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [:]
}

extension ConversationRequest: Payload {
    typealias RequestType = ConversationRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("title", String.self),
        ("participants", [Int].self),
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
