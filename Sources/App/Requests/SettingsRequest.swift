//
//  SettingsRequest.swift
//  App
//
//  Created by Niklas Sauer on 11.02.18.
//

import Foundation
import Vapor

enum SettingsFail: APIFail {
    case missingParameters([MissingParameter])
    case invalidPrivacyLevel
    
    enum MissingParameter {
        case privacy
        case communityRadius
        case trafficRadius
    }
}

struct SettingsRequest: Codable {
    let privacy: PrivacyLevel
    let communityRadius: Int
    let trafficRadius: Int
    
    static func validate(_ req: Request) throws -> SettingsRequest {
        var missingFields = [SettingsFail.MissingParameter]()
        
        var privacy: String?
        var communityRadius: Int?
        var trafficRadius: Int?

        do {
            privacy = try req.content.get(String.self, at: "privacy").await(on: req)
        } catch {
            missingFields.append(.privacy)
        }
        
        do {
            communityRadius = try req.content.get(Int.self, at: "communityRadius").await(on: req)
        } catch {
            missingFields.append(.communityRadius)
        }
        
        do {
            trafficRadius = try req.content.get(Int.self, at: "trafficRadius").await(on: req)
        } catch {
            missingFields.append(.trafficRadius)
        }
        
        guard missingFields.isEmpty else {
            throw SettingsFail.missingParameters(missingFields)
        }
        
        guard let privacyLevel = PrivacyLevel(rawValue: privacy!) else {
            throw SettingsFail.invalidPrivacyLevel
        }
        
        return SettingsRequest(privacy: privacyLevel, communityRadius: communityRadius!, trafficRadius: trafficRadius!)
    }
}
