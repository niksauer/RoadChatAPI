//
//  APIFail.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation

protocol APIFail: Error { }

enum RequestFail: APIFail {
    case missingParameters([String])
    case invalidTypeForParameters([String])
    case mismatchedContraints(Error)
}

enum RegisterFail: APIFail {
    case emailTaken
    case usernameTaken
}

enum LoginFail: APIFail {
    
}

enum SettingsFail: APIFail {
    
}

enum ProfileFail: APIFail {
    case invalidSexType
}

enum CarFail: APIFail {
    
}

enum TrafficFail: APIFail {
    
}

enum CommunityFail: APIFail {
    
}


