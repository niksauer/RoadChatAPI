//
//  CarRequest.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor
import Validation

struct CarRequest: Codable {
    let manufacturer: String
    let model: String
    let production: Date
    let performance: Int?
    let color: Int?
}

extension CarRequest: Validatable {
    static var validations: Validations = [
        key(\CarRequest.manufacturer): IsCount(1...50),
        key(\CarRequest.model): IsCount(1...50),
    ]
}

extension CarRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [
        key(\CarRequest.performance): IsCount(0...2000),
        key(\CarRequest.color): IsColor(),
    ]
}

extension CarRequest: RequestBody {
    typealias RequestType = CarRequest
    
    static var requiredParameters: Parameters = [
        ("manufacturer", "BMW"),
        ("model", "118d"),
        ("production", Date())
    ]
    
    static var optionalParameters: Parameters = [
        ("performance", 142),
        ("color", 255),
    ]
}
