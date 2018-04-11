//
//  DirectMessageRequest.swift
//  App
//
//  Created by Niklas Sauer on 19.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension DirectMessageRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<DirectMessageRequest> {
        var validations = Validations(DirectMessageRequest.self)
        try validations.add(\.message, .count(1...1000))
        return validations
    }
}

//extension DirectMessageRequest: OptionallyValidatable {
//    static var optionalValidations: OptionallyValidatable.Validations = [:]
//}

extension DirectMessageRequest: Payload {
    typealias RequestType = DirectMessageRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("time", Date.self),
        ("message", String.self),
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
