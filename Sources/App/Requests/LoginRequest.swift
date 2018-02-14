//
//  LoginRequest.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor

struct LoginRequest: Codable, Validatable {
    let user: String
    let password: String
    
    // Validatable
    typealias RequestType = LoginRequest
    
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] = [
        ("user", "inik"),
        ("password", "safeharbour")
    ]
}
