//
//  CommunityMessageRequest.swift
//  App
//
//  Created by Niklas Sauer on 08.02.18.
//

import Foundation
import Vapor

enum CommunityMessageFail: APIFail{
    case missingParameters([MissingParameter])
    
    enum MissingParameter {
        case senderID
        case time
        case location
        case message
    }
}

struct CommunityMessageRequest: Codable {
    let senderID: Int
    let time: Date
    let location: String
    let message: String
    
    static func validate(_ req: Request) throws -> CommunityMessageRequest {
        var missingFields = [CommunityMessageFail.MissingParameter]()
        
        var senderID: Int?
        var time: Double?
        var location: String?
        var message: String?
        
        do{
            senderID = try req.content.get(Int.self, at: "senderID").await(on: req)
        } catch{
            missingFields.append(.senderID)
        }
        do{
            time = try req.content.get(Double.self, at: "time").await(on: req)
        } catch{
            missingFields.append(.time)
        }
        do{
            location = try req.content.get(String.self, at: "location").await(on: req)
        } catch {
            missingFields.append(.location)
        }
        do{
            message = try req.content.get(String.self, at: "message").await(on: req)
        } catch{
            missingFields.append(.message)
        }
        guard missingFields.isEmpty else{
            throw CommunityMessageFail.missingParameters(missingFields)
        }
        return CommunityMessageRequest(senderID: senderID!, time: Date(timeIntervalSince1970: time!), location: location!, message: message!)
        
    }
    
}
