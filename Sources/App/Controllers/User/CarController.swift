//
//  CarController.swift
//  App
//
//  Created by Niklas Sauer on 14.02.18.
//

import Foundation
import Vapor
import Fluent
import RoadChatKit

/// Controls basic CRUD operations on `Car`s.
final class CarController {
    
    /// Returns a parameterized `Car`.
    func get(_ req: Request) throws -> Future<Car> {
        return try req.parameter(Car.self)
    }
    
    /// Updates a parameterized `Car`.
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        let car = try req.parameter(Car.self).await(on: req)
        try req.user().checkOwnership(for: car, on: req)
        
        let updatedCar = try CarRequest.extract(from: req)
        
        car.manufacturer = updatedCar.manufacturer
        car.model = updatedCar.model
        car.production = updatedCar.production
        car.performance = updatedCar.performance
        car.color = updatedCar.color
        
        return car.update(on: req).transform(to: .ok)
    }
    
    /// Deletes a parameterized `Car`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let car = try req.parameter(Car.self).await(on: req)
        try req.user().checkOwnership(for: car, on: req)
        
        return car.delete(on: req).transform(to: .ok)
    }
    
}
