//
//  ProfileRequest.swift
//  App
//
//  Created by Niklas Sauer on 12.02.18.
//

import Foundation
import Vapor

enum ProfileFail: APIFail {
    case missingParameters([MissingParameter])
    case invalidSexType
    
    enum MissingParameter {
        case sex
        case firstName
        case lastName
        case birth
        case streetName
        case streetNumber
        case postalCode
        case country
        case profession
    }
}

struct ProfileRequest: Codable {
    let sex: SexType
    let firstName: String
    let lastName: String
    let birth: Date
    let streetName: String
    let streetNumber: Int
    let postalCode: Int
    let country: String
    let profession: String
    
    static func validate(_ req: Request) throws -> ProfileRequest {
        var missingFields = [ProfileFail.MissingParameter]()
        
        var sex: String!
        var firstName: String!
        var lastName: String!
        var birth: Double!
        var streetName: String!
        var streetNumber: Int!
        var postalCode: Int!
        var country: String!
        var profession: String!
        
        do {
            sex = try req.content.get(String.self, at: "sex").await(on: req)
        } catch {
            missingFields.append(.sex)
        }
        
        do {
            firstName = try req.content.get(String.self, at: "firstName").await(on: req)
        } catch {
            missingFields.append(.firstName)
        }
        
        do {
            lastName = try req.content.get(String.self, at: "lastName").await(on: req)
        } catch {
            missingFields.append(.lastName)
        }
        
        do {
            birth = try req.content.get(Double.self, at: "birth").await(on: req)
        } catch {
            missingFields.append(.birth)
        }
        
        do {
            streetName = try req.content.get(String.self, at: "streetName").await(on: req)
        } catch {
            missingFields.append(.streetName)
        }
        
        do {
            streetNumber = try req.content.get(Int.self, at: "streetNumber").await(on: req)
        } catch {
            missingFields.append(.streetNumber)
        }
        
        do {
            postalCode = try req.content.get(Int.self, at: "postalCode").await(on: req)
        } catch {
            missingFields.append(.postalCode)
        }
        
        do {
            country = try req.content.get(String.self, at: "country").await(on: req)
        } catch {
            missingFields.append(.country)
        }
        
        do {
            profession = try req.content.get(String.self, at: "profession").await(on: req)
        } catch {
            missingFields.append(.profession)
        }
        
        guard missingFields.isEmpty else {
            throw ProfileFail.missingParameters(missingFields)
        }
        
        guard let sexType = SexType(rawValue: sex) else {
            throw ProfileFail.invalidSexType
        }
        
        return ProfileRequest(sex: sexType, firstName: firstName, lastName: lastName, birth: Date(timeIntervalSince1970: birth), streetName: streetName, streetNumber: streetNumber, postalCode: postalCode, country: country, profession: profession)
    }
}
