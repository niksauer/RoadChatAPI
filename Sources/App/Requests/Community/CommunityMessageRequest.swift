//
//  CommunityMessageRequest.swift
//  App
//
//  Created by Niklas Sauer on 08.02.18.
//

import Foundation
import Vapor
import Validation
import RoadChatKit

extension CommunityMessageRequest: Validatable, Reflectable {
    public static var validations: Validations = [
        key(\CommunityMessageRequest.title): IsCount(1...140),
        
        key(\CommunityMessageRequest.course): IsCount(0.0...360.0)
    ]
}

extension CommunityMessageRequest: OptionallyValidatable {
    static var optionalValidations: OptionallyValidatable.Validations = [
        key(\CommunityMessageRequest.message): IsCount(0...280),
    ]
}

extension CommunityMessageRequest: Payload {
    typealias RequestType = CommunityMessageRequest
    
    static var requiredParameters: [Payload.Parameter] = [
        ("time", Date()),
        ("message", "Stau auf der A3"),
        
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
