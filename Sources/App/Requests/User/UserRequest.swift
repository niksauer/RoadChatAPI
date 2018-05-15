//
//  UserRequest.swift
//  App
//
//  Created by Niklas Sauer on 18.04.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension UserRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<UserRequest> {
        let validations = Validations(UserRequest.self)
        return validations
    }
}

extension UserRequest: Payload {
    static var requiredParameters: [Payload.Parameter] = []
    
    static var optionalParameters: [Payload.Parameter] = [
        ("email", String.self),
        ("username", String.self),
        ("password", String.self)
    ]
}
