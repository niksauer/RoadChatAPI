//
//  RequestBody.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Fluent
import Validation

protocol RequestBody {
    associatedtype RequestType: Validatable
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] { get }
}

extension RequestBody {
    static func extract(from req: Request) throws -> RequestType {
        var missingParameters = [String]()
        var invalidParameters = [String]()
        
        for (parameter, _) in requiredParameters {
            do {
                _ = try req.content.get(String.self, at: parameter).await(on: req)
            } catch {
                missingParameters.append(parameter.makeBasicKey().stringValue)
            }
        }
    
        guard missingParameters.isEmpty else {
            throw RequestFail.missingParameters(missingParameters)
        }
        
        for (parameter, type) in requiredParameters {
            let parameterName = parameter.makeBasicKey().stringValue
            var typeName = String()
            
            do {
                switch type {
                case is String:
                    typeName = "String"
                    _ = try req.content.get(String.self, at: parameter).await(on: req)
                case is Int:
                    typeName = "Int"
                    _ = try req.content.get(Int.self, at: parameter).await(on: req)
                case is Double:
                    typeName = "Double"
                    _ = try req.content.get(Double.self, at: parameter).await(on: req)
                case is Date:
                    typeName = "Date"
                    _ = try req.content.get(Date.self, at: parameter).await(on: req)
                case is Bool:
                    typeName = "Bool"
                    _ = try req.content.get(Bool.self, at: parameter).await(on: req)
                default:
                    throw Abort(.badRequest)
                }
            } catch {
                invalidParameters.append("\(parameterName); expected: \(typeName)")
            }
        }
        
        guard invalidParameters.isEmpty else {
            throw RequestFail.invalidTypeForParameters(invalidParameters)
        }
        
        let body = try req.content.decode(RequestType.self).await(on: req)
        
        do {
            try body.validate()
        } catch {
            throw RequestFail.mismatchedContraints(error)
        }
        
        return body
    }
}
