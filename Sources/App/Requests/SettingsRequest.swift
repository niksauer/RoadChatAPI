//
//  SettingsRequest.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor

struct SettingsRequest: Codable, Validatable {
    let communityRadius: Int
    let trafficRadius: Int
    let showFirstName: Bool
    let showLastName: Bool
    let showBirth: Bool
    let showSex: Bool
    let showAddress: Bool
    let showProfession: Bool
    
    // Validatable
    typealias RequestType = SettingsRequest
    
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] = [
        ("communityRadius", 10),
        ("trafficRadius", 5),
        ("showFirstName", true),
        ("showLastName", false),
        ("showBirth", false),
        ("showSex", true),
        ("showAddress", false),
        ("showProfession", true)
    ]
}
