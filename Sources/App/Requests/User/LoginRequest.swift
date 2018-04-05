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
    public static var validations: Validations = [
        key(\LoginRequest.user): IsASCII(),
        key(\LoginRequest.password): IsCount(8...) && IsASCII()
    ]
}

extension LoginRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [:]
}

extension LoginRequest: Payload {
    typealias RequestType = LoginRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("user", "inik"),
        ("password", "safeharbour")
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
