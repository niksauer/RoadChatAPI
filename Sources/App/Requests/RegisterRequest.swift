//
//  RegisterRequest.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor

struct RegisterRequest: Codable, Validatable {
    let email: String
    let username: String
    let password: String
    
    // Validatable
    typealias RequestType = RegisterRequest
    
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] = [
        ("email", "nik.sauer@me.com"),
        ("username", "inik"),
        ("password", "safeharbour")
    ]
}
