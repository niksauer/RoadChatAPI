//
//  SettingsRequest.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension SettingsRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<SettingsRequest> {
        var validations = Validations(SettingsRequest.self)
        try validations.add(\.communityRadius, .range(0...500))
        try validations.add(\.trafficRadius, .range(0...500))
        return validations
    }
}

//extension SettingsRequest: OptionallyValidatable {
//    static func optionalValidations() throws -> Validations<SettingsRequest> {
//        let validations = Validations(SettingsRequest.self)
//        return validations
//    }
//}

extension SettingsRequest: Payload {
    static var requiredParameters: [Payload.Parameter] = [
        ("communityRadius", Int.self),
        ("trafficRadius", Int.self),
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
