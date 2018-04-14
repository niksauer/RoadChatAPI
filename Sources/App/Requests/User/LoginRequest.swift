//
//  LoginRequest.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension LoginRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<LoginRequest> {
        var validations = Validations(LoginRequest.self)
        try validations.add(\.user, .ascii)
        try validations.add(\.password, .count(8...) && .ascii)
        return validations
    }
}

//extension LoginRequest: OptionallyValidatable {
//    static var optionalValidations: OptionallyValidatable.Validations = [:]
//}

extension LoginRequest: Payload {
    typealias RequestType = LoginRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("user", String.self),
        ("password", String.self)
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
