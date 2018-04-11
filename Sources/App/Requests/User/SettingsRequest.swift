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
        let validations = Validations(SettingsRequest.self)
//        try validations.add(\.communityRadius, .count(0...500))
//        try validations.add(\.trafficRadius, .count(0...50))
        return validations
    }
}

//extension SettingsRequest: OptionallyValidatable {
//    static var optionalValidations: OptionallyValidatable.Validations = [:]
//}

extension SettingsRequest: Payload {
    typealias RequestType = SettingsRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("communityRadius", Int.self),
        ("trafficRadius", Int.self),
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
