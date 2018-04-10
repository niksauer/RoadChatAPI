//
//  APIFail.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation

protocol APIFail: Error {
    var message: String { get }
}

enum RequestFail: APIFail {
    case missingOrInvalidParameters([String])
    case mismatchedContraints(Error)
    
    var message: String {
        switch self {
        case .missingOrInvalidParameters(let parameters):
            return "Found missing or invalid parameters: \(parameters.description)"
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
    case noAssociatedLocation
    
    var message: String {
        switch self {
        case .invalidParticipants(let participants):
            return "Invalid participants: \(participants)"
        case .minimumParticipants:
            return "A conversation must have at least one participant."
        case .noAssociatedLocation:
            return "No location has been associated to this user."
        }
    }
}
