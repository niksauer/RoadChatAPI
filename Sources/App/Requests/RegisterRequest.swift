//
//  RegisterRequest.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor

struct RegisterRequest: Codable {
    var email: String
    var username: String
    var password: String
}
