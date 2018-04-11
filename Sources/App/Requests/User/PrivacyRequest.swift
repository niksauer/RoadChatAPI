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
    public static func validations() throws -> Validations<PrivacyRequest> {
        let validations = Validations(PrivacyRequest.self)
        return validations
    }
}

//extension PrivacyRequest: OptionallyValidatable {
//    static var optionalValidations: OptionallyValidatable.Validations = [:]
//}

extension PrivacyRequest: Payload {
    typealias RequestType = PrivacyRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("shareLocation", Bool.self),
        ("showFirstName", Bool.self),
        ("showLastName", Bool.self),
        ("showBirth", Bool.self),
        ("showSex", Bool.self),
        ("showAddress", Bool.self),
        ("showBiography", Bool.self)
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
