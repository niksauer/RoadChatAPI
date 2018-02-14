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
    
    // Validatable
    typealias RequestType = SettingsRequest
    
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] = [
        ("communityRadius", 10),
        ("trafficRadius", 5),
    ]
}
