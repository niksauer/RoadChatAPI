//
//  RegisterRequest.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension RegisterRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<RegisterRequest> {
        var validations = Validations(RegisterRequest.self)
        try validations.add(\.email, .email)
        try validations.add(\.username, .count(4...) && .alphanumeric)
        try validations.add(\.password, .count(8...) && .ascii)
        return validations
    }
}

//extension RegisterRequest: OptionallyValidatable {
//    static var optionalValidations: OptionallyValidatable.Validations = [:]
//}

extension RegisterRequest: Payload {
    static var requiredParameters: [Payload.Parameter] = [
        ("email", String.self),
        ("username", String.self),
        ("password", String.self)
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
