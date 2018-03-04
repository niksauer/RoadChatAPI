//
//  PrivacyRequest.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension PrivacyRequest: Validatable {
    public static var validations: Validations = [:]
}

extension PrivacyRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [:]
}

extension PrivacyRequest: Payload {
    typealias RequestType = PrivacyRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("shareLocation", false),
        ("showFirstName", true),
        ("showLastName", false),
        ("showBirth", false),
        ("showSex", true),
        ("showAddress", false),
        ("showBiography", true)
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
