//
//  SettingsRequest.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension SettingsRequest: Validatable {
    public static var validations: Validations = [
        key(\SettingsRequest.communityRadius): IsCount(0...500),
        key(\SettingsRequest.trafficRadius): IsCount(0...50)
    ]
}

extension SettingsRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [:]
}

extension SettingsRequest: Payload {
    typealias RequestType = SettingsRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("communityRadius", 10),
        ("trafficRadius", 5),
    ]
    
    static var optionalParameters: [Payload.Parameter] = []
}
