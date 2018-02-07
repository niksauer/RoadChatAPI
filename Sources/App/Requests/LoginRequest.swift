//
//  LoginRequest.swift
//  App
//
//  Created by Niklas Sauer on 06.02.18.
//

import Foundation
import Vapor

struct LoginRequest: Codable {
    var email: String
    var password: String
}
