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
    public static var validations: Validations = [
        key(\TrafficMessageRequest.type): IsTrafficType(),
    ]
}

extension TrafficMessageRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [
        key(\TrafficMessageRequest.message): IsCount(0...280)
    ]
}

extension TrafficMessageRequest: Payload {
    typealias RequestType = TrafficMessageRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("type", String.self),
        ("time", Date.self),
        
        ("latitude", Double.self),
        ("longitude", Double.self),
        ("altitude", Double.self),
        ("horizontalAccuracy", Double.self),
        ("verticalAccuracy", Double.self),
        ("course", Double.self),
        ("speed", Double.self),
    ]
    
    static var optionalParameters: [Payload.Parameter] = [
        ("note", String.self)
    ]
}
