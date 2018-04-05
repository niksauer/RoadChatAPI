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
    private static func findMissingParameters(in req: Request, required parameters: [Parameter]) -> [Future<Parameter>] {
        var missingParameters = [Future<Parameter>]()
        
        for parameter in parameters {
            switch parameter.type {
            case is [Any]:
                req.content.get([String].self, at: parameter.name).catch({ _ in
                    missingParameters.append(Future.map(on: req) { parameter })
                })
            default:
                req.content.get(String.self, at: parameter.name).catch({ _ in
                    missingParameters.append(Future.map(on: req) { parameter })
                })
            }
        }

        return missingParameters
    }
    
    private static func findInvalidParameters(in req: Request, expected parameters: [Parameter]) -> [Future<String>] {
        var invalidParameters = [Future<String>]()
        
        for parameter in parameters {
            switch parameter.type {
            case is String:
                req.content.get(String.self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { "\(parameter.name); expected: String" })
                })
            case is Int:
                req.content.get(Int.self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { "\(parameter.name); expected: Int" })
                })
            case is Double:
                req.content.get(Double.self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { "\(parameter.name); expected: Double" })
                })
            case is Date:
                req.content.get(Date.self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { "\(parameter.name); expected: Date" })
                })
            case is Bool:
                req.content.get(Bool.self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { "\(parameter.name); expected: Bool" })
                })
            case is [Int]:
                req.content.get([Int].self, at: parameter.name).catch({ _ in
                    invalidParameters.append(Future.map(on: req) { "\(parameter.name); expected: Array<Int>" })
                })
            default:
                // unknown data type in request
                break
            }
        }
        
        return invalidParameters
    }
    
    static func extract(from req: Request) throws -> Future<RequestType> {
        return findMissingParameters(in: req, required: requiredParameters).flatMap(to: RequestType.self, on: req, { missingParameters in
            guard missingParameters.isEmpty else {
                throw RequestFail.missingParameters(missingParameters.map({ $0.name.makeBasicKey().stringValue }))
            }
            
            return findInvalidParameters(in: req, expected: requiredParameters).flatMap(to: RequestType.self, on: req) { invalidParameters in
                guard invalidParameters.isEmpty else {
                    throw RequestFail.invalidTypeForParameters(invalidParameters)
                }
                
                return findMissingParameters(in: req, required: optionalParameters).flatMap(to: RequestType.self, on: req) { missingOptionalParameters in
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
                    
                    return findInvalidParameters(in: req, expected: presentOptionalParameters).flatMap(to: RequestType.self, on: req) { invalidOptionalParameters in
                        guard invalidOptionalParameters.isEmpty else {
                            throw RequestFail.invalidTypeForParameters(invalidOptionalParameters)
                        }
                        
                        return try req.content.decode(RequestType.self).map(to: RequestType.self) { request in
                            do {
                                try request.validate()
                                try request.validateOptionals()
                            } catch {
                                throw RequestFail.mismatchedContraints(error)
                            }
                            
                            return request
                        }
                    }
                }
            }
        })
    }
}

