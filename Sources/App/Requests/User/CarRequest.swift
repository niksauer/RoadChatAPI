//
//  CarRequest.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension CarRequest: Validatable, Reflectable {
    public static func validations() throws -> Validations<CarRequest> {
        var validations = Validations(CarRequest.self)
        try validations.add(\.manufacturer, .count(1...50))
        try validations.add(\.model, .count(1...50))
        return validations
    }
}

//extension CarRequest: OptionallyValidatable {
//    static var optionalValidations: OptionallyValidatable.Validations = [
//        key(\CarRequest.performance): IsCount(0...2000),
//        key(\CarRequest.color): IsColor(),
//    ]
//}

extension CarRequest: Payload {
    typealias RequestType = CarRequest

    static var requiredParameters: [Payload.Parameter] = [
        ("manufacturer", String.self),
        ("model", String.self),
        ("production", Date.self)
    ]

    static var optionalParameters: [Payload.Parameter] = [
        ("performance", Int.self),
        ("color", String.self),
    ]
}

