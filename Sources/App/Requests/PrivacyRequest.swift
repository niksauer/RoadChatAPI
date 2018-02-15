//
//  PrivacyRequest.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Validation

struct PrivacyRequest: Codable {
    let showFirstName: Bool
    let showLastName: Bool
    let showBirth: Bool
    let showSex: Bool
    let showAddress: Bool
    let showProfession: Bool
}

extension PrivacyRequest: Validatable {
    static var validations: Validations = [:]
}

extension PrivacyRequest: RequestBody {
    typealias RequestType = PrivacyRequest
    
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] = [
        ("showFirstName", true),
        ("showLastName", false),
        ("showBirth", false),
        ("showSex", true),
        ("showAddress", false),
        ("showProfession", true)
    ]
}
