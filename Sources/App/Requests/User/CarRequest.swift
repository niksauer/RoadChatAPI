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
    public static var validations: Validations = [
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

extension CarRequest: Payload {
    typealias RequestType = CarRequest

    static var requiredParameters: [Payload.Parameter] = [
        ("manufacturer", String.self),
        ("model", String.self),
        ("production", Date.self)
    ]

    static var optionalParameters: [Payload.Parameter] = [
        ("performance", Int.self),
        ("color", Int.self),
    ]
}

