//
//  UserRouter.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor

class UserRouter: RouteCollection {
    func boot(router: Router) throws {
        let userController = UserController()
        let loginController = LoginController()
        
        // /user
        router.post(use: userController.create)
        
        // /user/login
        router.get("login", use: loginController.login)
        
        // /user/logout
        router.grouped(try User.tokenAuthMiddleware()).get("logout", use: loginController.logout)
        
        // /user/User.parameter
        let user = router.grouped(User.parameter)
        let authenticatedUser = user.grouped(try User.tokenAuthMiddleware())
        
        user.get(use: userController.get)
        authenticatedUser.put(use: userController.update)
        authenticatedUser.delete(use: userController.delete)

        // /user/User.parameter/settings
        authenticatedUser.group("settings", use: { group in
            group.get(use: userController.getSettings)
            group.put(use: userController.updateSettings)
        })
        
        // /user/User.parameter/cars
//        user.get("cars", use: )
//        authenticatedUser.post("cars", use: )
        
        // /user/User.parameter/profile
        user.get("profile", use: userController.getProfile)
        authenticatedUser.put("profile", use: userController.createOrUpdateProfile)
    }
}
