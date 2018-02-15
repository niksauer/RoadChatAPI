//
//  RequestBody.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Validation

protocol RequestBody {
    associatedtype RequestType: Validatable, OptionallyValidatable
    typealias Parameters = [(name: BasicKeyRepresentable, type: Decodable)]
    static var requiredParameters: Parameters { get }
    static var optionalParameters: Parameters { get }
}

extension RequestBody {
    private static func checkParameterPresence(in req: Request, parameters: Parameters) throws {
        var missingParameters = [String]()
        
        for parameter in parameters {
            do {
                _ = try req.content.get(String.self, at: parameter.name).await(on: req)
            } catch {
                let keyPath = parameter.name.makeBasicKey().stringValue
                missingParameters.append(keyPath)
            }
        }
        
        guard missingParameters.isEmpty else {
            throw RequestFail.missingParameters(missingParameters)
        }
    }
    
    private static func checkParameterType(in req: Request, parameters: Parameters) throws {
        var invalidParameters = [String]()
        
        for parameter in parameters {
//            let keyPath = parameter.name.makeBasicKey().stringValue
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
                default:
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
        try checkParameterPresence(in: req, parameters: requiredParameters)
        try checkParameterType(in: req, parameters: requiredParameters)
        try checkParameterType(in: req, parameters: optionalParameters)
        
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

