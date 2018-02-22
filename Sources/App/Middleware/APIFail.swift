//
//  APIFail.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor

protocol APIFail: Error {
    var message: String { get }
}

enum RequestFail: APIFail {
    case missingParameters([String])
    case invalidTypeForParameters([String])
    case mismatchedContraints(Error)
    
    var message: String {
        switch self {
        case .missingParameters(let parameters):
            return "Missing required parameters: \(parameters.description)"
        case .invalidTypeForParameters(let parameters):
            return "Invalid type for parameters: \(parameters)"
        case .mismatchedContraints(let violations):
            return "Mismatched constraints: \(violations)"
        }
    }
}

enum RegisterFail: APIFail {
    case emailTaken
    case usernameTaken
    
    var message: String {
        switch self {
        case .emailTaken:
            return "This email address has already been registered."
        case .usernameTaken:
            return "This username has already been registered."
        }
    }
}

enum ConversationFail: APIFail {
    case invalidParticipants([Int])
    case minimumParticipants
    
    var message: String {
        switch self {
        case .invalidParticipants(let participants):
            return "Invalid participants: \(participants)"
        case .minimumParticipants:
            return "A conversation must have at least one participant."
        }
    }
}
