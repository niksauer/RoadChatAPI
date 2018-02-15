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
    let senderID: Int
    let type: String
    let time: Date
    let location: String
    let direction: Double
    let note: String?
}

extension TrafficMessageRequest: Validatable {
    static var validations: Validations = [
        key(\TrafficMessageRequest.type): IsTrafficType(),
        key(\TrafficMessageRequest.location): IsAlphanumeric(),
    ]
}

extension TrafficMessageRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [
        key(\TrafficMessageRequest.note): IsCount(0...280)
    ]
}

extension TrafficMessageRequest: RequestBody {
    typealias RequestType = TrafficMessageRequest
    
    static var requiredParameters: Parameters = [
        ("senderID", 1),
        ("type", "traffic jam"),
        ("time", Date()),
        ("location", "a22exF"),
        ("direction", "North"),
    ]
    
    static var optionalParameters: Parameters = [
        ("note", "Achtung, Kinder auf der Fahrbahn")
    ]
}
