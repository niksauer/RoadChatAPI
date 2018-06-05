//
//  LocationRequest.swift
//  App
//
//  Created by Niklas Sauer on 25.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension LocationRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<LocationRequest> {
        let validations = Validations(LocationRequest.self)
        return validations
    }
}

//extension LocationRequest: OptionallyValidatable {
//    static var optionalValidations: OptionallyValidatable.Validations = [:]
//}

extension LocationRequest: Payload {
    static var requiredParameters: [Payload.Parameter] = [
        ("time", Date.self),
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
