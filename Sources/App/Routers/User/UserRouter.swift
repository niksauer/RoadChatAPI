//
//  UserRouter.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor
import RoadChatKit

class UserRouter: RouteCollection {
    func boot(router: Router) throws {
        let authMiddleware = User.tokenAuthMiddleware(database: .mysql)
        let userController = UserController()
        let loginController = LoginController()
        let conversationController = ConversationController()
        
        // /user
        router.post(use: userController.create)
        
        // /user/login
        router.post("login", use: loginController.login)
        
        // /user/logout
        router.grouped(authMiddleware).get("logout", use: loginController.logout)
        
        // /user/User.parameter
        let user = router.grouped(User.parameter)
        let authenticatedUser = user.grouped(authMiddleware)
        
        user.get(use: userController.get)
        authenticatedUser.put(use: userController.update)
        authenticatedUser.delete(use: userController.delete)

        // /user/User.parameter/settings
        authenticatedUser.group("settings", configure: { group in
            group.get(use: userController.getSettings)
            group.put(use: userController.updateSettings)
            
            // /user/User.parameter/settings/privacy
            group.get("privacy", use: userController.getPrivacy)
            group.put("privacy", use: userController.updatePrivacy)
        })
        
        // /user/User.parameter/profile
        user.get("profile", use: userController.getProfile)
        authenticatedUser.put("profile", use: userController.createOrUpdateProfile)
        
        // /user/User.parameter/cars
        user.get("cars", use: userController.getCars)
        authenticatedUser.post("cars", use: userController.createCar)
        
        // /user/User.parameter/location
        authenticatedUser.group("location", configure: { group in
            group.get(use: userController.getLocation)
            group.put(use: userController.createOrUpdateLocation)
        })

        // /user/User.parameter/trafficMessages
        authenticatedUser.get("trafficMessages", use: userController.getTrafficMessages)
        
        // /user/User.parameter/communityMessages
        authenticatedUser.get("communityMessages", use: userController.getCommunityMessages)
        
        // /user/User.parameter/conversations
        authenticatedUser.get("conversations", use: conversationController.index)
    }
}
