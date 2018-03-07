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

extension DirectMessageRequest: Validatable {
    public static var validations: Validations = [
        key(\DirectMessageRequest.message): IsCount(1...1000),
    ]
}

extension DirectMessageRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [:]
}

extension DirectMessageRequest: Payload {
    typealias RequestType = DirectMessageRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("time", Date()),
        ("message", "Hey, wie gehts?"),
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
