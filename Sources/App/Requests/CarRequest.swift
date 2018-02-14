//
//  CarRequest.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor

struct CarRequest: Codable, Validatable {
    let manufacturer: String
    let model: String
    let production: Date
    let performance: Int?
    let color: String?
    
    // Validatable
    typealias RequestType = CarRequest
    
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] = [
        ("manufacturer", "BMW"),
        ("model", "118d"),
        ("production", Date())
    ]
}
