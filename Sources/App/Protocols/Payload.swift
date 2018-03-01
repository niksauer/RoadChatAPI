//
//  Payload.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Validation

protocol Payload {
    associatedtype RequestType: Validatable, OptionallyValidatable
    typealias Parameter = (name: BasicKeyRepresentable, type: Decodable)
    static var requiredParameters: [Parameter] { get }
    static var optionalParameters: [Parameter] { get }
}

extension Payload {    
    private static func findMissingParameters(in req: Request, required parameters: [Parameter]) -> [Parameter] {
        var missingParameters = [Parameter]()
        
        for parameter in parameters {
            switch parameter.type {
            case is [Any]:
                req.content.get([String].self, at: parameter.name).catch({ _ in missingParameters.append(parameter) })
            default:
                req.content.get(String.self, at: parameter.name).catch({ _ in missingParameters.append(parameter) })
            }
        }

        return missingParameters
    }
    
    private static func checkParameterType(in req: Request, parameters: [Parameter]) throws {
        var invalidParameters = [String]()
        
        func addInvalidParameter(_ parameter: Parameter, typeName: String) {
            invalidParameters.append("\(parameter.name); expected: \(typeName)")
        }
        
        
        for parameter in parameters {
            switch parameter.type {
            case is String:
                req.content.get(String.self, at: parameter.name).catch({ _ in addInvalidParameter(parameter, typeName: "String") })
            case is Int:
                req.content.get(Int.self, at: parameter.name).catch({ _ in addInvalidParameter(parameter, typeName: "Int") })
            case is Double:
                req.content.get(Double.self, at: parameter.name).catch({ _ in addInvalidParameter(parameter, typeName: "Double") })
            case is Date:
                req.content.get(Date.self, at: parameter.name).catch({ _ in addInvalidParameter(parameter, typeName: "Date") })
            case is Bool:
                req.content.get(Bool.self, at: parameter.name).catch({ _ in addInvalidParameter(parameter, typeName: "Bool") })
            case is [Int]:
                req.content.get([Int].self, at: parameter.name).catch({ _ in addInvalidParameter(parameter, typeName: "Array<Int>") })
            default:
                // unknown data type in request
                throw Abort(.badRequest)
            }
        }
        
        guard invalidParameters.isEmpty else {
            throw RequestFail.invalidTypeForParameters(invalidParameters)
        }
    }
    
    static func extract(from req: Request) throws -> Future<RequestType> {
        let missingParameters = findMissingParameters(in: req, required: requiredParameters)
        
        guard missingParameters.isEmpty else {
            throw RequestFail.missingParameters(missingParameters.map({ $0.name.makeBasicKey().stringValue }))
        }
        
        try checkParameterType(in: req, parameters: requiredParameters)
        
        let missingOptionalParameters = findMissingParameters(in: req, required: optionalParameters)
        var presentOptionalParameters = [Parameter]()
    
        for parameter in optionalParameters {
            let parameterName = parameter.name.makeBasicKey().stringValue
            
            if !missingOptionalParameters.contains(where: { missingParameter in
                let missingParameterName = missingParameter.name.makeBasicKey().stringValue
                return missingParameterName == parameterName
            }) {
                presentOptionalParameters.append(parameter)
            }
        }
        
        try checkParameterType(in: req, parameters: presentOptionalParameters)
        
        return try req.content.decode(RequestType.self).map(to: RequestType.self) { body in
            do {
                try body.validate()
                try body.validateOptionals()
            } catch {
                throw RequestFail.mismatchedContraints(error)
            }
            
            return body
        }
        
    }
}

