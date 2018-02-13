//
//  TrafficMessageRequest.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor

struct TrafficMessageRequest: Codable {
    let senderID: Int
    let time: Date
    let location: String
    let message: String
}
