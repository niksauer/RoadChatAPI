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
    
    typealias Resource = Car
    typealias Result = Car.PublicCar
    
    /// Returns a parameterized `Car`.
    func get(_ req: Request) throws -> Future<Result> {
        return try req.parameter(Car.self).map(to: Result.self) { car in
            return try car.publicCar()
        }
    }
    
    /// Updates a parameterized `Car`.
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { car in
            try req.user().checkOwnership(for: car, on: req)
            
            return try CarRequest.extract(from: req).flatMap(to: HTTPStatus.self) { updatedCar in
                car.manufacturer = updatedCar.manufacturer
                car.model = updatedCar.model
                car.production = updatedCar.production
                car.performance = updatedCar.performance
                car.color = updatedCar.color
                
                return car.update(on: req).transform(to: .ok)
            }
        }
    }
    
    /// Deletes a parameterized `Car`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { car in
            try req.user().checkOwnership(for: car, on: req)
            return car.delete(on: req).transform(to: .ok)
        }
    }
    
}
