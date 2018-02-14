//
//  ProfileRequest.swift
//  App
//
//  Created by Niklas Sauer on 12.02.18.
//

import Foundation
import Vapor

struct ProfileRequest: Codable, Validatable {
    let firstName: String
    let lastName: String
    let birth: Date
    let sex: String?
    let streetName: String?
    let streetNumber: Int?
    let postalCode: Int?
    let country: String?
    let profession: String?
    
    // Validatable
    typealias RequestType = ProfileRequest
    
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] = [
        ("firstName", "Niklas"),
        ("lastName", "Sauer"),
        ("birth", Date()),
    ]
}
