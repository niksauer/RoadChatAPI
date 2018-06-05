//
//  Validators.swift
//  App
//
//  Created by Niklas Sauer on 15.02.18.
//

import Foundation
import Validation
import RoadChatKit

// Sex Type Validator
struct SexTypeValidator: ValidatorType {
    var validatorReadable: String {
        return "a valid sex type"
    }
    
    func validate(_ type: String) throws {
        guard let _ = SexType(rawValue: type) else {
            throw BasicValidationError("is not a valid sex type")
        }
    }
}

extension Validator where T == String {
    public static var sexType: Validator<T> {
        return SexTypeValidator().validator()
    }
}

// RGB Color Validator
struct RGBColorValidator: ValidatorType {
    let maxRGB = 16777215

    var validatorReadable: String {
        return "a valid color"
    }
    
    func validate(_ int: Int) throws {
        guard int <= maxRGB else {
            throw BasicValidationError("is not a valid RGB color")
        }
    }
}

extension Validator where T == Int {
    public static var rgbColor: Validator<T> {
        return RGBColorValidator().validator()
    }
}

// Traffic Type Validator
struct TrafficTypeValidator: ValidatorType {
    var validatorReadable: String {
        return "a valid traffic type"
    }

    func validate(_ type: String) throws {
        guard let _ = TrafficType(rawValue: type) else {
            throw BasicValidationError("is not a valid traffic type")
        }
    }
}

extension Validator where T == String {
    public static var trafficType: Validator<T> {
        return TrafficTypeValidator().validator()
    }
}
