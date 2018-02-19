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
    typealias Parameters = [(name: BasicKeyRepresentable, type: Decodable)]
    static var requiredParameters: Parameters { get }
    static var optionalParameters: Parameters { get }
}

extension Payload {
    typealias Parameter = (name: BasicKeyRepresentable, type: Decodable)
    
    private static func findMissingParameters(in req: Request, required parameters: Parameters) -> Parameters {
        var missingParameters = [Parameter]()
        
        for parameter in parameters {
            do {
                _ = try req.content.get(String.self, at: parameter.name).await(on: req)
            } catch {
                missingParameters.append(parameter)
            }
        }

        return missingParameters
    }
    
    private static func checkParameterType(in req: Request, parameters: Parameters) throws {
        var invalidParameters = [String]()
        
        for parameter in parameters {
            var typeName = String()
            
            do {
                switch parameter.type {
                case is String:
                    typeName = "String"
                    _ = try req.content.get(String.self, at: parameter.name).await(on: req)
                case is Int:
                    typeName = "Int"
                    _ = try req.content.get(Int.self, at: parameter.name).await(on: req)
                case is Double:
                    typeName = "Double"
                    _ = try req.content.get(Double.self, at: parameter.name).await(on: req)
                case is Date:
                    typeName = "Date"
                    _ = try req.content.get(Date.self, at: parameter.name).await(on: req)
                case is Bool:
                    typeName = "Bool"
                    _ = try req.content.get(Bool.self, at: parameter.name).await(on: req)
                case is Array<Int>:
                    typeName = "Array<Int>"
                    _ = try req.content.get([Int].self, at: parameter.name).await(on: req)
                default:
                    // unknown data type in request
                    throw Abort(.badRequest)
                }
            } catch {
                invalidParameters.append("\(parameter.name); expected: \(typeName)")
            }
        }
        
        guard invalidParameters.isEmpty else {
            throw RequestFail.invalidTypeForParameters(invalidParameters)
        }
    }
    
    static func extract(from req: Request) throws -> RequestType {
        let missingParameters = findMissingParameters(in: req, required: requiredParameters)
        
        guard missingParameters.isEmpty else {
            throw RequestFail.missingParameters(missingParameters.map({ $0.name.makeBasicKey().stringValue }))
        }
        
        try checkParameterType(in: req, parameters: requiredParameters)
        
        let missingOptionalParameters = findMissingParameters(in: req, required: optionalParameters)
        var presentOptionalParameters = Parameters()
    
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
        
        let body = try req.content.decode(RequestType.self).await(on: req)
        
        do {
            try body.validate()
            try body.validateOptionals()
        } catch {
            throw RequestFail.mismatchedContraints(error)
        }
        
        return body
    }
}

