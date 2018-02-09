//
//  CommunityRequest.swift
//  App
//
//  Created by Niklas Sauer on 08.02.18.
//

import Foundation
import Vapor

struct CommunityRequest: Codable {
    let senderID: Int
    let time: Date
    let location: String
    let message: String
}
