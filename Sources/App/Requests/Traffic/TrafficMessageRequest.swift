//
//  TrafficMessageRequest.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension TrafficMessageRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<TrafficMessageRequest> {
        var validations = Validations(TrafficMessageRequest.self)
        try validations.add(\.type, .trafficType)
        return validations
    }
}

//extension TrafficMessageRequest: OptionallyValidatable {
//    static var optionalValidations: OptionallyValidatable.Validations = [
//        key(\TrafficMessageRequest.message): IsCount(0...255)
//    ]
//}

extension TrafficMessageRequest: Payload {
    static var requiredParameters: [Payload.Parameter] = [
        ("type", TrafficType.RawValue.self),
        ("time", Date.self),
        ("location", Location.self)
    ]
    
    static var optionalParameters: [Payload.Parameter] = [
        ("message", String.self)
    ]
}
