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
//    static var optionalValidations: OptionallyValidatable.Validations = [
//        key(\CommunityMessageRequest.message): IsCount(0...280),
//    ]
//}

extension CommunityMessageRequest: Payload {
    typealias RequestType = CommunityMessageRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("time", Date.self),
        ("message", String.self),
        
        ("latitude", Double.self),
        ("longitude", Double.self),
        ("altitude", Double.self),
        ("horizontalAccuracy", Double.self),
        ("verticalAccuracy", Double.self),
        ("course", Double.self),
        ("speed", Double.self),
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
