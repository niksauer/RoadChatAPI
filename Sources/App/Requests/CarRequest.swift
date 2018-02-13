//
//  CarRequest.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor

enum CarFail: APIFail {
    case missingParameters([MissingParameter])
    
    enum MissingParameter {
        case manufacturer
        case model
        case production
        case performance
        case color
    }
}

struct CarRequest: Codable {
    let manufacturer: String
    let model: String
    let production: Date
    let performance: Int
    let color: String
    
    static func validate(_ req: Request) throws -> CarRequest {
        var missingFields = [CarFail.MissingParameter]()
        
        var manufacturer: String!
        var model: String!
        var production: Double!
        var performance: Int!
        var color: String!
        
        do {
            manufacturer = try req.content.get(String.self, at: "manufacturer").await(on: req)
        } catch {
            missingFields.append(.manufacturer)
        }
        
        do {
            model = try req.content.get(String.self, at: "model").await(on: req)
        } catch {
            missingFields.append(.model)
        }
        
        do {
            production = try req.content.get(Double.self, at: "production").await(on: req)
        } catch {
            missingFields.append(.production)
        }
        
        do {
            performance = try req.content.get(Int.self, at: "performance").await(on: req)
        } catch {
            missingFields.append(.performance)
        }
        
        do {
            color = try req.content.get(String.self, at: "color").await(on: req)
        } catch {
            missingFields.append(.color)
        }
        
        guard missingFields.isEmpty else {
            throw CarFail.missingParameters(missingFields)
        }

        return CarRequest(manufacturer: manufacturer, model: model, production: Date(timeIntervalSince1970: production), performance: performance, color: color)
    }
}
