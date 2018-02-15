//
//  OptionallyValidatable.swift
//  App
//
//  Created by Niklas Sauer on 15.02.18.
//

import Foundation
import Validation

protocol OptionallyValidatable {
    typealias Validations = [ValidationKey : Validator]
    static var optionalValidations: Validations { get }
}

extension OptionallyValidatable {
    func validateOptionals() throws {
        var errors: [ValidationError] = []
        
        for (key, validation) in Self.optionalValidations {
            let data = (self[keyPath: key.keyPath] as ValidationDataRepresentable).makeValidationData()
            
            if case .null = data {
                continue
            }
            
            do {
                try validation.validate(data)
            } catch var error as ValidationError {
                error.codingPath += key.codingPath
                errors.append(error)
            }
        }
        
        if !errors.isEmpty {
            throw errors.first!
        }
    }
}
