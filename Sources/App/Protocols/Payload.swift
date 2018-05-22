//
//  Payload.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Validation

protocol Payload: Decodable, Validatable {
    typealias Parameter = (name: BasicKeyRepresentable, type: Decodable.Type)
    static var requiredParameters: [Parameter] { get }
    static var optionalParameters: [Parameter] { get }
}

extension Payload {    
    private static func findMissingOrInvalidParameters(in req: Request, expected parameters: [Parameter]) -> [Future<Parameter>] {
        var invalidParameters = [Future<Parameter>]()
        
        for parameter in parameters {
            switch parameter.type {
            case is String.Type:
                req.content.get(String.self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { parameter })
                })
            case is Int.Type:
                req.content.get(Int.self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { parameter })
                })

            case is Double.Type:
                req.content.get(Double.self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { parameter })
                })

            case is Date.Type:
                req.content.get(Date.self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { parameter })
                })
            case is Bool.Type:
                req.content.get(Bool.self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { parameter })
                })

            case is [Int].Type:
                req.content.get([Int].self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { parameter })
                })
            default:
                // unknown data type in request
                break
            }
        }

        return invalidParameters
    }
    
    static func extract(from req: Request) throws -> Future<Self> {
        return findMissingOrInvalidParameters(in: req, expected: requiredParameters).flatMap(to: Self.self, on: req) { invalidParameters in
            guard invalidParameters.isEmpty else {
                throw RequestFail.missingOrInvalidParameters(invalidParameters.map({ "\($0.name.makeBasicKey().stringValue) (expectedType: \(String(describing: $0.type.self))" }))
            }
            
            return findMissingOrInvalidParameters(in: req, expected: optionalParameters).flatMap(to: Self.self, on: req) { invalidOptionalParameters in
                var presentOptionalParameters = [Parameter]()
                
                for parameter in optionalParameters {
                    let parameterName = parameter.name.makeBasicKey().stringValue
                
                    if !invalidOptionalParameters.contains(where: { invalidParameter in
                        let missingParameterName = invalidParameter.name.makeBasicKey().stringValue
                        return missingParameterName == parameterName
                    }) {
                        presentOptionalParameters.append(parameter)
                    }
                }
                
                return findMissingOrInvalidParameters(in: req, expected: presentOptionalParameters).flatMap(to: Self.self, on: req) { presentInvalidOptionalParameters in
                    guard presentInvalidOptionalParameters.isEmpty else {
                        throw RequestFail.missingOrInvalidParameters(presentInvalidOptionalParameters.map({ "\($0.name.makeBasicKey().stringValue) (expectedType: \(String(describing: $0.type.self))" }))
                    }
                    
                    return try req.content.decode(Self.self).map(to: Self.self) { request in
                        do {
                            try request.validate()
//                            try request.validateOptionals()
                        } catch {
                            throw RequestFail.mismatchedContraints(error)
                        }
                        
                        return request
                    }
                }
            }
        }
    }
}

