//
//  Validators.swift
//  App
//
//  Created by Niklas Sauer on 15.02.18.
//

import Foundation
import Validation
import RoadChatKit

struct ValidationFail: ValidationError {
    var reason: String
    var codingPath: [CodingKey]
}

struct IsSex: Validator {
    enum Sex: String {
        case male, female, other
    }
    
    // Validator
    var inverseMessage: String = "valid sex"
    
    func validate(_ data: ValidationData) throws {
        switch data {
        case .string(let string):
            guard let _ = Sex(rawValue: string) else {
                throw BasicValidationError("is not a valid sex")
            }
        default:
            throw BasicValidationError("is not a string")
        }
    }
}

struct IsColor: Validator {
    let maxRGB = 16777215
    
    // Validator
    var inverseMessage: String = "valid RGB color"
    
    func validate(_ data: ValidationData) throws {
        switch data {
        case .int(let int):
            guard int <= maxRGB else {
                throw BasicValidationError("is not a valid RGB color")
            }
        default:
            throw BasicValidationError("is not an integer")
        }
    }
}

struct IsTrafficType: Validator {
    // Validator
    var inverseMessage: String = "valid traffic type"
    
    func validate(_ data: ValidationData) throws {
        switch data {
        case .string(let string):
            guard let _ = TrafficType(rawValue: string) else {
                throw BasicValidationError("is not a valid traffic type")
            }
        default:
            throw BasicValidationError("is not a string")
        }
    }
}
