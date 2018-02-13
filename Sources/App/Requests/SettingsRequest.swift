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
        case communityRadius
        case trafficRadius
        case showsLastName
        case showsFirstName
        case showsBirth
        case showsSex
        case showsAddress
        case showsProfession
    }
}

struct SettingsRequest: Codable {
    let communityRadius: Int
    let trafficRadius: Int
    let showsFirstName: Bool
    let showsLastName: Bool
    let showsBirth: Bool
    let showsSex: Bool
    let showsAddress: Bool
    let showsProfession: Bool
    
    static func validate(_ req: Request) throws -> SettingsRequest {
        var missingFields = [SettingsFail.MissingParameter]()
        
        var communityRadius: Int!
        var trafficRadius: Int!
        var showsFirstName: Bool!
        var showsLastName: Bool!
        var showsBirth: Bool!
        var showsSex: Bool!
        var showsAddress: Bool!
        var showsProfession: Bool!
        
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
        
        do {
            showsFirstName = try req.content.get(Bool.self, at: "showsFirstName").await(on: req)
        } catch {
            missingFields.append(.showsFirstName)
        }
        
        do {
            showsLastName = try req.content.get(Bool.self, at: "showsLastName").await(on: req)
        } catch {
            missingFields.append(.showsLastName)
        }
        
        do {
            showsBirth = try req.content.get(Bool.self, at: "showsBirth").await(on: req)
        } catch {
            missingFields.append(.showsBirth)
        }
        
        do {
            showsSex = try req.content.get(Bool.self, at: "showsSex").await(on: req)
        } catch {
            missingFields.append(.showsSex)
        }
        
        do {
            showsAddress = try req.content.get(Bool.self, at: "showsAddress").await(on: req)
        } catch {
            missingFields.append(.showsAddress)
        }
        
        do {
            showsProfession = try req.content.get(Bool.self, at: "showsProfession").await(on: req)
        } catch {
            missingFields.append(.showsProfession)
        }
        
        guard missingFields.isEmpty else {
            throw SettingsFail.missingParameters(missingFields)
        }
        
        return SettingsRequest(communityRadius: communityRadius, trafficRadius: trafficRadius, showsFirstName: showsFirstName, showsLastName: showsLastName, showsBirth: showsBirth, showsSex: showsSex, showsAddress: showsAddress, showsProfession: showsProfession)
    }
}
