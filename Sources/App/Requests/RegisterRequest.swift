//
//  RegisterRequest.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor

enum RegisterFail: APIFail {
    case missingParameters([MissingParameter])
    case emailTaken
    case usernameTaken
    
    enum MissingParameter {
        case email
        case username
        case password
    }
}

struct RegisterRequest: Codable {
    let email: String
    let username: String
    let password: String
    
    static func validate(_ req: Request) throws -> RegisterRequest {
        var missingFields = [RegisterFail.MissingParameter]()
        
        var email: String?
        var username: String?
        var password: String?
            
        do {
            email = try req.content.get(String.self, at: "email").await(on: req)
        } catch {
            missingFields.append(.email)
        }
        
        do {
            username = try req.content.get(String.self, at: "username").await(on: req)
        } catch {
            missingFields.append(.username)
        }
        
        do {
            password = try req.content.get(String.self, at: "password").await(on: req)
        } catch {
            missingFields.append(.password)
        }
        
        guard missingFields.isEmpty else {
            throw RegisterFail.missingParameters(missingFields)
        }
    
        return RegisterRequest(email: email!, username: username!, password: password!)
    }
}
