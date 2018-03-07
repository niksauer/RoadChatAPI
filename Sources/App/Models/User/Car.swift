//
//  Car.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import RoadChatKit

extension Car: SQLiteModel, Migration {
    public static var idKey: WritableKeyPath<Car, Int?> {
        return \Car.id
    }
    
    static var entity: String {
        return "car"
    }
}

extension Car: Ownable {
    var owner: Parent<Car, User> {
        return parent(\Car.userID)
    }
}

extension Car: Parameter {
    public static func make(for parameter: String, using container: Container) throws -> Future<Car> {
        guard let id = Int(parameter) else {
            // id must be integer
            throw Abort(.badRequest)
        }
        
        return container.requestConnection(to: .mysql).flatMap(to: Car.self) { database in
            return Car.find(id, on: database).map(to: Car.self) { existingCar in
                guard let car = existingCar else {
                    // user not found
                    throw Abort(.notFound)
                }
                
                return car
            }
        }
    }
}

extension Car.PublicCar: Content {}
