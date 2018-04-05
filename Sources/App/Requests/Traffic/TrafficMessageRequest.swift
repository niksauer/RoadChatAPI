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
        key(\TrafficMessageRequest.course): IsCount(0.0...360.0)
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
        ("type", "traffic jam"),
        ("time", Date()),
        
        ("latitude", 45.123),
        ("longitude", 42.0),
        ("altitude", 24.2),
        ("horizontalAccuracy", 34.0),
        ("verticalAccuracy", 34.0),
        ("course", 0.0),
        ("speed", 60.0),
    ]
    
    static var optionalParameters: [Payload.Parameter] = [
        ("note", "Achtung, Kinder auf der Fahrbahn")
    ]
}
