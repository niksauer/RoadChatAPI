//
//  UserController.swift
//  App
//
//  Created by Niklas Sauer on 05.02.18.
//

import Foundation
import Vapor
import Fluent
import Crypto

/// Controls basic CRUD operations on `User`s.
final class UserController {
    
    /// Saves a new `User` to the database.
    func create(_ req: Request) throws -> Future<User.PublicUser> {
        let registerRequest = try RegisterRequest.validate(req)
        
        return User.query(on: req).filter(\User.email == registerRequest.email).first().flatMap(to: User.PublicUser.self) { existingUser in
            guard existingUser == nil else {
                // email already registered
                throw RegisterFail.emailTaken
            }
            
            return User.query(on: req).filter(\User.username == registerRequest.username).first().flatMap(to: User.PublicUser.self) { existingUser in
                guard existingUser == nil else {
                    // username taken
                    throw RegisterFail.usernameTaken
                }
                
                let hasher = try req.make(BCryptHasher.self)
                let hashedPassword = try hasher.make(registerRequest.password)
                
                let newUser = User(email: registerRequest.email, username: registerRequest.username, password: hashedPassword)
            
                return newUser.create(on: req).map(to: User.PublicUser.self) { user in
                    // further user setup
                    _ = Settings(userID: try user.requireID()).create(on: req)
            
                    return try user.publicUser()
                }
            }
        }
    }
    
    /// Returns a parameterized `User`.
    func get(_ req: Request) throws -> Future<User.PublicUser> {
        return try req.parameter(User.self).map(to: User.PublicUser.self) { user in
            return try user.publicUser()
        }
    }
    
    /// Updates a parameterized `User`.
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try checkOwnership(req)
        let updatedUser = try RegisterRequest.validate(req)
        
        let hasher = try req.make(BCryptHasher.self)
        let hashedPassword = try hasher.make(updatedUser.password)
        
        user.email = updatedUser.email
        user.username = updatedUser.username
        user.password = hashedPassword
        
        return user.update(on: req).transform(to: .ok)
    }
    
    /// Deletes a parameterized `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try checkOwnership(req)
        
        // delete requested user and revoke all of his tokens
        return try user.authTokens.query(on: req).delete().flatMap(to: HTTPStatus.self) {
            return user.delete(on: req).transform(to: .ok)
        }
    }
    
    /// Returns the settings for a parameterized `User`.
    func getSettings(_ req: Request) throws -> Future<Settings.PublicSettings> {
        let user = try checkOwnership(req)
        
        return try user.getSettings(on: req).map(to: Settings.PublicSettings.self) { settings in
            return settings.publicSettings()
        }
    }
    
    /// Updates the settings for a parameterized `User`.
    func updateSettings(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try checkOwnership(req)
        let updatedSettings = try SettingsRequest.validate(req)
        
        return try user.getSettings(on: req).flatMap(to: HTTPStatus.self) { settings in
            settings.privacy = updatedSettings.privacy.rawValue
            settings.communityRadius = updatedSettings.communityRadius
            settings.trafficRadius = updatedSettings.trafficRadius
            
            return settings.update(on: req).transform(to: .ok)
        }
    }
    
    /// Returns the profile for a parameterized `User`.
    func getProfile(_ req: Request) throws -> Future<Profile.PublicProfile> {
        return try req.parameter(User.self).flatMap(to: Profile.PublicProfile.self) { user in
            return try user.getProfile(on: req).map(to: Profile.PublicProfile.self) { profile in
                guard let profile = profile else {
                    // no profile associated to user
                    throw Abort(.notFound)
                }
                
                return profile.publicProfile()
            }
        }
    }
    
    /// Creates or updates the profile for a parameterized `User`.
    func createOrUpdateProfile(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try checkOwnership(req)
        let profileRequest = try ProfileRequest.validate(req)
        
        return try user.getProfile(on: req).flatMap(to: HTTPStatus.self) { existingProfile in
            guard let profile = existingProfile else {
                let newProfile = Profile(userID: try user.requireID(), profileRequest: profileRequest)
                return newProfile.create(on: req).transform(to: .ok)
            }

            profile.sex = profileRequest.sex.rawValue
            profile.firstName = profileRequest.firstName
            profile.lastName = profileRequest.firstName
            profile.birth = profileRequest.birth
            profile.streetName = profileRequest.streetName
            profile.streetNumber = profileRequest.streetNumber
            profile.postalCode = profileRequest.postalCode
            profile.country = profileRequest.country
            profile.profession = profileRequest.profession
            
            return profile.update(on: req).transform(to: .ok)
        }
    }
    
    /// Returns all `Cars`s associated to a parameterized `User`.
    func getCars(_ req: Request) throws -> Future<[Car.PublicCar]> {
        return try req.parameter(User.self).flatMap(to: [Car.PublicCar].self) { user in
            return try user.getCars(on: req).map(to: [Car.PublicCar].self) { cars in
                return try cars.map({ try $0.publicCar() })
            }
        }
    }
    
    /// Saves a new `Car` to the database which is associated to a parameterized `User`.
    func createCar(_ req: Request) throws -> Future<Car.PublicCar> {
        let user = try checkOwnership(req)
        let carRequest = try CarRequest.validate(req)
        
        let newCar = Car(userID: try user.requireID(), carRequest: carRequest)
        
        return newCar.create(on: req).map(to: Car.PublicCar.self) { car in
            return try car.publicCar()
        }
    }
    
    /// Returns all `CommunityMessage`s associated to a parameterized `User`.
    func getCommunityMessages(_ req: Request) throws -> Future<[CommunityMessage]> {
        return try req.parameter(User.self).flatMap(to: [CommunityMessage].self) { user in
            return try user.getCommunityMessages(on: req)
        }
    }
    
    /// Checks resource ownership for a parameterized `User` according to the supplied token.
    private func checkOwnership(_ req: Request) throws -> User {
        let requestedUser = try req.parameter(User.self).await(on: req)
        let authenticatedUser = try req.user()
        
        guard try requestedUser.requireID() == authenticatedUser.requireID() else {
            // unowned resource
            throw Abort(.forbidden)
        }
        
        return authenticatedUser
    }

}
