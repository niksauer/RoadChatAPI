//
//  CommunityMessageRequest.swift
//  App
//
//  Created by Niklas Sauer on 08.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension CommunityMessageRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<CommunityMessageRequest> {
        var validations = Validations(CommunityMessageRequest.self)
        try validations.add(\.title, .count(1...140))
        return validations
    }
}

//extension CommunityMessageRequest: OptionallyValidatable {
//    static func optionalValidations() throws -> Validations<CommunityMessageRequest> {
//        let validations = Validations(CommunityMessageRequest.self)
//        try validations.add(\.message, .count(0...280))
//        return validations
//    }
//}

extension CommunityMessageRequest: Payload {
    static var requiredParameters: [Payload.Parameter] = [
        ("title", String.self),
        ("time", Date.self),
        ("location", Location.self)
    ]
    
    static var optionalParameters: [Payload.Parameter] = [
        ("message", String.self),
    ]
}
