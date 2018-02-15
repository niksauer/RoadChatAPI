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
        
        for (parameter, type) in requiredParameters {
            do {
                switch type {
                case is String:
                    _ = try req.content.get(String.self, at: parameter).await(on: req)
                case is Int:
                    _ = try req.content.get(Int.self, at: parameter).await(on: req)
                case is Double:
                    _ = try req.content.get(Double.self, at: parameter).await(on: req)
                case is Date:
                    _ = try req.content.get(Date.self, at: parameter).await(on: req)
                case is Bool:
                    _ = try req.content.get(Bool.self, at: parameter).await(on: req)
                default:
                    throw Abort(.badRequest)
                }
            } catch {
                missingParameters.append(parameter.makeBasicKey().stringValue)
            }
        }
    
        guard missingParameters.isEmpty else {
            throw RequestFail.missingParameters(missingParameters)
        }
        
        let body = try req.content.decode(RequestType.self).await(on: req)
        
        do {
            try body.validate()
        } catch {
            throw RequestFail.invalidParameters(error)
        }
        
        return body
    }
}
