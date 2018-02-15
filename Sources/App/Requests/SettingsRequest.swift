//
//  SettingsRequest.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor
import Validation

struct SettingsRequest: Codable {
    let communityRadius: Int
    let trafficRadius: Int
}

extension SettingsRequest: Validatable {
    static var validations: Validations = [
        key(\SettingsRequest.communityRadius): IsCount(0...500),
        key(\SettingsRequest.trafficRadius): IsCount(0...50)
    ]
}

extension SettingsRequest: RequestBody {
    typealias RequestType = SettingsRequest
    
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] = [
        ("communityRadius", 10),
        ("trafficRadius", 5),
    ]
}
