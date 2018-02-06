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
        router.get("logout", use: loginController.logout)
        
        // /user/User.parameter
        let user = router.grouped(User.parameter)
        
        user.get(use: userController.get)
//        user.put(use: )
        user.delete(use: userController.delete)
        
        // /user/User.parameter/settings
        user.group("settings", use: { group in
//            group.get(use: )
//            group.put(use: )
        })
        
        // /user/User.parameter/cars
        user.group("cars", use: { group in
//            group.get(use: )
//            group.post(use: )
        })
        
        // /user/User.parameter/profile
        user.group("profile", use: { group in
//            group.get(use: )
//            group.post(use: )
//            group.put(use: )
        })
    }
}
