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
    
    private let uploadDirectory: URL
    
    init(uploadDirectory: URL) {
        self.uploadDirectory = uploadDirectory
    }
    
    /// Returns a parameterized `Car`.
    func get(_ req: Request) throws -> Future<Result> {
        return try req.parameters.next(Car.self).map(to: Result.self) { car in
            return try car.publicCar()
        }
    }
    
    /// Updates a parameterized `Car`.
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Resource.self).flatMap(to: HTTPStatus.self) { car in
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
        return try req.parameters.next(Resource.self).flatMap(to: HTTPStatus.self) { car in
            try req.user().checkOwnership(for: car, on: req)
            return car.delete(on: req).transform(to: .ok)
        }
    }

    func getImage(_ req: Request) throws -> Future<PublicFile> {
        return try req.parameters.next(Resource.self).map(to: PublicFile.self) { car in
            let fileManager = FileManager()
            let filename = "car\(try car.requireID()).jpg"
            let url = self.uploadDirectory.appendingPathComponent(filename)
            
            guard let data = fileManager.contents(atPath: url.path) else {
                throw Abort(.notFound)
            }
           
            return PublicFile(filename: filename, data: data)
        }
    }
    
    func uploadImage(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Resource.self).flatMap(to: HTTPStatus.self) { car in
            try req.user().checkOwnership(for: car, on: req)
            
            return try req.content.decode(Multipart.self).map(to: HTTPStatus.self) { image in
                let acceptableTypes = [MediaType.jpeg]
                
                guard let mimeType = image.file.contentType, acceptableTypes.contains(mimeType) else {
                    throw Abort(.badRequest)
                }
                
                let url = self.uploadDirectory.appendingPathComponent("car\(try car.requireID()).jpg")
                _ = try image.file.data.write(to: url)
                
                return .ok
            }
        }
    }
    
}
