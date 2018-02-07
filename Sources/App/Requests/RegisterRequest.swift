//
//  RegisterRequest.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor

struct RegisterRequest: Codable {
    let email: String
    let username: String
    let password: String
}
