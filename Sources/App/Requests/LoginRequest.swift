//
//  LoginRequest.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor
import Validation

struct LoginRequest: Codable {
    let user: String
    let password: String
}

extension LoginRequest: Validatable {
    static var validations: Validations = [
        key(\LoginRequest.user): IsASCII(),
        key(\LoginRequest.password): IsCount(8...) && IsASCII()
    ]
}

extension LoginRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [:]
}

extension LoginRequest: RequestBody {
    typealias RequestType = LoginRequest
    
    static var requiredParameters: Parameters = [
        ("user", "inik"),
        ("password", "safeharbour")
    ]
    
    static var optionalParameters: Parameters = []
}
