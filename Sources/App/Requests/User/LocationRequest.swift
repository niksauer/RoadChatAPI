//
//  LocationRequest.swift
//  App
//
//  Created by Niklas Sauer on 25.02.18.
//

import Foundation
import Vapor
import Validation

struct LocationRequest: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let horizontalAccuracy: Double
    let verticalAccuracy: Double
    let course: Double
    let speed: Double
}

extension LocationRequest: Validatable {
    static var validations: Validations = [
        key(\LocationRequest.course): IsCount(0.0...360.0)
    ]
}

extension LocationRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [:]
}

extension LocationRequest: Payload {
    typealias RequestType = LocationRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("latitude", 45.123),
        ("longitude", 42.0),
        ("altitude", 24.2),
        ("horizontalAccuracy", 34.0),
        ("verticalAccuracy", 34.0),
        ("course", 0.0),
        ("speed", 60.0),
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
