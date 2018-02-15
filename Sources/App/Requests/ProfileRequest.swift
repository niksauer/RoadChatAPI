//
//  ProfileRequest.swift
//  App
//
//  Created by Niklas Sauer on 12.02.18.
//

import Foundation
import Vapor
import Validation

struct ProfileRequest: Codable {
    let firstName: String
    let lastName: String
    let birth: Date
    let sex: String?
    let description: String?
    let streetName: String?
    let streetNumber: Int?
    let postalCode: Int?
    let country: String?
}

extension ProfileRequest: Validatable {
    static var validations: Validations = [
        key(\ProfileRequest.firstName): IsCount(1...50),
        key(\ProfileRequest.lastName): IsCount(1...50),
//        key(\ProfileRequest.birth): IsDate(),
//        key(\ProfileRequest.sex): IsSex(),
//        key(\ProfileRequest.description): IsCount(0...280),
//        key(\ProfileRequest.streetName): IsCount(0...50),
//        key(\ProfileRequest.streetNumber): IsInt(),
//        key(\ProfileRequest.postalCode): IsInt(),
//        key(\ProfileRequest.country): IsCount(0...50),
    ]
}

extension ProfileRequest: RequestBody {
    typealias RequestType = ProfileRequest
    
    static var requiredParameters: [(BasicKeyRepresentable, Decodable)] = [
        ("firstName", "Niklas"),
        ("lastName", "Sauer"),
        ("birth", Date()),
    ]
}
