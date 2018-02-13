//
//  Car.swift
//  App
//
//  Created by Niklas Sauer on 13.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class Car: Content {
    var id: Int?
    var userID: User.ID
    var manufacturer: String
    var model: String
    var production: Date
    var performance: Int
    var color: String
    
    init(userID: User.ID, manufacturer: String, model: String, production: Date, performance: Int, color: String) {
        self.userID = userID
        self.manufacturer = manufacturer
        self.model = model
        self.production = production
        self.performance = performance
        self.color = color
    }
    
    convenience init(userID: User.ID, carRequest: CarRequest) {
        self.init(userID: userID, manufacturer: carRequest.manufacturer, model: carRequest.model, production: carRequest.production, performance: carRequest.performance, color: carRequest.color)
    }
}

extension Car {
    func publicCar() throws -> PublicCar {
        return try PublicCar(car: self)
    }
    
    struct PublicCar: Content {
        let id: Int
        let userID: Int
        let manufacturer: String
        let model: String
        let production: Date
        let performance: Int
        let color: String
        
        init(car: Car) throws {
            self.id = try car.requireID()
            self.userID = car.userID
            self.manufacturer = car.manufacturer
            self.model = car.model
            self.production = car.production
            self.performance = car.performance
            self.color = car.color
        }
    }
}

extension Car: SQLiteModel, Migration {
    static var idKey: ReferenceWritableKeyPath<Car, Int?> {
        return \Car.id
    }
    
    var user: Parent<Car, User> {
        return parent(\Car.userID)
    }
}
