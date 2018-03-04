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

final class Car: Content {
    var id: Int?
    var userID: User.ID
    var manufacturer: String
    var model: String
    var production: Date
    var performance: Int?
    var color: Int?
    
    init(userID: User.ID, manufacturer: String, model: String, production: Date, performance: Int?, color: Int?) {
        self.userID = userID
        self.manufacturer = manufacturer
        self.model = model
        self.production = production
        self.performance = performance
        self.color = color
    }
    
    convenience init(userID: User.ID, carRequest request: CarRequest) {
        self.init(userID: userID, manufacturer: request.manufacturer, model: request.model, production: request.production, performance: request.performance, color: request.color)
    }
}

extension Car: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<Car, Int?> {
        return \Car.id
    }
}

extension Car: Ownable {
    var owner: Parent<Car, User> {
        return parent(\Car.userID)
    }
}

extension Car: Parameter {
    static func make(for parameter: String, using container: Container) throws -> Future<Car> {
        guard let id = Int(parameter) else {
            // id must be integer
            throw Abort(.badRequest)
        }
        
        return container.requestConnection(to: .sqlite).flatMap(to: Car.self) { database in
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
