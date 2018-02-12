//
//  LoginRequest.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor

enum LoginFail: APIFail {
    case missingParameters([MissingParameter])
    
    enum MissingParameter {
        case user
        case password
    }
}

struct LoginRequest: Codable {
    let user: String
    let password: String
    
    static func validate(_ req: Request) throws -> LoginRequest {
        var missingFields = [LoginFail.MissingParameter]()
        
        var user: String?
        var password: String?
        
        do {
            user = try req.content.get(String.self, at: "user").await(on: req)
        } catch {
            missingFields.append(.user)
        }
        
        do {
            password = try req.content.get(String.self, at: "password").await(on: req)
        } catch {
            missingFields.append(.password)
        }
        
        guard missingFields.isEmpty else {
            throw LoginFail.missingParameters(missingFields)
        }
        
        return LoginRequest(user: user!, password: password!)
    }
}
