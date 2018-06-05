//
//  CarRouter.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor
import RoadChatKit

class CarRouter: RouteCollection {
    
    private let uploadDirectory: URL
    
    init(uploadDirectory: URL) {
        self.uploadDirectory = uploadDirectory
    }
    
    func boot(router: Router) throws {
        let authMiddleware = User.tokenAuthMiddleware(database: .mysql)
        let carController = CarController(uploadDirectory: uploadDirectory)
        
        // /car/Car.parameter
        let car = router.grouped(Car.parameter)
        let authenticatedCar = car.grouped(authMiddleware)
        
        car.get(use: carController.get)
        authenticatedCar.put(use: carController.update)
        authenticatedCar.delete(use: carController.delete)
        
        // /car/Car.parameter/image
        car.get("image", use: carController.getImage)
        authenticatedCar.put("image", use: carController.uploadImage)
    }
}

