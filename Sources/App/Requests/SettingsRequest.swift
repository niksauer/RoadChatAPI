//
//  SettingsRequest.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor

struct SettingsRequest: Codable {
    let privacy: String
    let communityRadius: Int
    let trafficRadius: Int
}
