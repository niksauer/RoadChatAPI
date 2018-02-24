//
//  CarRouter.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor

class CarRouter: RouteCollection {
    func boot(router: Router) throws {
        let authMiddleware = try User.tokenAuthMiddleware(database: .sqlite)
        let carController = CarController()
        
        // /car/Car.parameter
        let car = router.grouped(Car.parameter)
        let authenticatedCar = car.grouped(authMiddleware)
        
        car.get(use: carController.get)
        authenticatedCar.put(use: carController.update)
        authenticatedCar.delete(use: carController.delete)
    }
}

