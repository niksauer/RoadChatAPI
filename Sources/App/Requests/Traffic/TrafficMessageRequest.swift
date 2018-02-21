//
//  TrafficMessageRequest.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor
import Validation

struct TrafficMessageRequest: Codable {
    let type: String
    let time: Date
    let note: String?
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let horizontalAccuracy: Double
    let verticalAccuracy: Double
    let course: Double
    let speed: Double
    
}

extension TrafficMessageRequest: Validatable {
    static var validations: Validations = [
        key(\TrafficMessageRequest.type): IsTrafficType()
    ]
}

extension TrafficMessageRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [
        key(\TrafficMessageRequest.note): IsCount(0...280)
    ]
}

extension TrafficMessageRequest: Payload {
    typealias RequestType = TrafficMessageRequest
    
    static var requiredParameters: Parameters = [
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
    
    static var optionalParameters: Parameters = [
        ("note", "Achtung, Kinder auf der Fahrbahn")
    ]
}
