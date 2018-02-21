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
    
    typealias Resource = User
    typealias Result = User.PublicUser
    
    /// Saves a new `User` to the database.
    func create(_ req: Request) throws -> Future<Result> {
        let registerRequest = try RegisterRequest.extract(from: req)
        
        return User.query(on: req).filter(\User.email == registerRequest.email).first().flatMap(to: Result.self) { existingUser in
            guard existingUser == nil else {
                // email already registered
                throw RegisterFail.emailTaken
            }
            
            return User.query(on: req).filter(\User.username == registerRequest.username).first().flatMap(to: Result.self) { existingUser in
                guard existingUser == nil else {
                    // username taken
                    throw RegisterFail.usernameTaken
                }
                
                let hasher = try req.make(BCryptHasher.self)
                let hashedPassword = try hasher.make(registerRequest.password)
                
                let newUser = User(email: registerRequest.email, username: registerRequest.username, password: hashedPassword)
            
                return newUser.create(on: req).map(to: Result.self) { user in
                    // further user setup
                    _ = Settings(userID: try user.requireID()).create(on: req)
                    _ = Privacy(userID: try user.requireID()).create(on: req)
            
                    return try newUser.publicUser(isOwner: true)
                }
            }
        }
    }
    
    /// Returns a parameterized `User`.
    func get(_ req: Request) throws -> Future<Result> {
        return try req.parameter(Resource.self).map(to: Result.self) { user in
            do {
                try req.checkOptionalOwnership(for: user)
                return try user.publicUser(isOwner: true)
            } catch {
                return try user.publicUser(isOwner: false)
            }
        }
    }
    
    /// Updates a parameterized `User`.
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.parameter(Resource.self).await(on: req)
        try req.user().checkOwnership(for: user, on: req)

        let updatedUser = try RegisterRequest.extract(from: req)
        
        let hasher = try req.make(BCryptHasher.self)
        let hashedPassword = try hasher.make(updatedUser.password)
        
        user.email = updatedUser.email
        user.username = updatedUser.username
        user.password = hashedPassword
        
        return user.update(on: req).transform(to: .ok)
    }
    
    /// Deletes a parameterized `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.parameter(Resource.self).await(on: req)
        try req.user().checkOwnership(for: user, on: req)
        
        // delete requested user and revoke all of his tokens
        return try user.authTokens.query(on: req).delete().flatMap(to: HTTPStatus.self) {
            return user.delete(on: req).transform(to: .ok)
        }
    }
    
    /// Returns the `Setting`s for a parameterized `User`.
    func getSettings(_ req: Request) throws -> Future<Settings.PublicSettings> {
        let user = try req.parameter(Resource.self).await(on: req)
        try req.user().checkOwnership(for: user, on: req)
        
        return try user.getSettings(on: req).map(to: Settings.PublicSettings.self) { settings in
            return settings.publicSettings()
        }
    }
    
    /// Updates the `Setting`s for a parameterized `User`.
    func updateSettings(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.parameter(Resource.self).await(on: req)
        try req.user().checkOwnership(for: user, on: req)
        
        let updatedSettings = try SettingsRequest.extract(from: req)
        
        return try user.getSettings(on: req).flatMap(to: HTTPStatus.self) { settings in
            settings.communityRadius = updatedSettings.communityRadius
            settings.trafficRadius = updatedSettings.trafficRadius
            
            return settings.update(on: req).transform(to: .ok)
        }
    }
    
    /// Returns the `Privacy` for a parameterized `User`.
    func getPrivacy(_ req: Request) throws -> Future<Privacy.PublicPrivacy> {
        let user = try req.parameter(Resource.self).await(on: req)
        try req.user().checkOwnership(for: user, on: req)
        
        return try user.getPrivacy(on: req).map(to: Privacy.PublicPrivacy.self) { privacy in
            return privacy.publicPrivacy()
        }
    }
    
    /// Updates the `Privacy` for a parameterized `User`.
    func updatePrivacy(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.parameter(Resource.self).await(on: req)
        try req.user().checkOwnership(for: user, on: req)
        
        let updatedPrivacy = try PrivacyRequest.extract(from: req)
        
        return try user.getPrivacy(on: req).flatMap(to: HTTPStatus.self) { privacy in
            privacy.showFirstName = updatedPrivacy.showFirstName
            privacy.showLastName = updatedPrivacy.showLastName
            privacy.showBirth = updatedPrivacy.showBirth
            privacy.showSex = updatedPrivacy.showSex
            privacy.showAddress = updatedPrivacy.showAddress
            privacy.showDescription = updatedPrivacy.showDescription
            
            return privacy.update(on: req).transform(to: .ok)
        }
    }
    
    /// Returns the `Profile` for a parameterized `User`.
    func getProfile(_ req: Request) throws -> Future<Profile.PublicProfile> {
        return try req.parameter(Resource.self).flatMap(to: Profile.PublicProfile.self) { user in
            return try user.getProfile(on: req).flatMap(to: Profile.PublicProfile.self) { profile in
                guard let profile = profile else {
                    // no profile associated to user
                    throw Abort(.notFound)
                }
            
                return try user.getPrivacy(on: req).map(to: Profile.PublicProfile.self) { privacy in
                    do {
                        try req.checkOptionalOwnership(for: user)
                        return profile.publicProfile(privacy: privacy, isOwner: true)
                    } catch {
                        return profile.publicProfile(privacy: privacy, isOwner: false)
                    }
                }
            }
        }
    }
    
    /// Creates or updates the `Profile` for a parameterized `User`.
    func createOrUpdateProfile(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.parameter(Resource.self).await(on: req)
        try req.user().checkOwnership(for: user, on: req)
        
        let profileRequest = try ProfileRequest.extract(from: req)
        
        return try user.getProfile(on: req).flatMap(to: HTTPStatus.self) { existingProfile in
            guard let profile = existingProfile else {
                let newProfile = Profile(userID: try user.requireID(), profileRequest: profileRequest)
                return newProfile.create(on: req).transform(to: .created)
            }
            
            profile.firstName = profileRequest.firstName
            profile.lastName = profileRequest.lastName
            profile.birth = profileRequest.birth
            profile.sex = profileRequest.sex
            profile.description = profileRequest.description
            profile.streetName = profileRequest.streetName
            profile.streetNumber = profileRequest.streetNumber
            profile.postalCode = profileRequest.postalCode
            profile.country = profileRequest.country
            
            return profile.update(on: req).transform(to: .ok)
        }
    }
    
    /// Returns all `Cars`s associated to a parameterized `User`.
    func getCars(_ req: Request) throws -> Future<[Car]> {
        return try req.parameter(Resource.self).flatMap(to: [Car].self) { user in
            return try user.getCars(on: req)
        }
    }
    
    /// Saves a new `Car` to the database which is associated to a parameterized `User`.
    func createCar(_ req: Request) throws -> Future<Car> {
        let user = try req.parameter(Resource.self).await(on: req)
        try req.user().checkOwnership(for: user, on: req)
        
        let carRequest = try CarRequest.extract(from: req)
        
        return Car(userID: try user.requireID(), carRequest: carRequest).create(on: req)
    }
    
    /// Returns all `TrafficMessage`s associated to a parameterized `User`.
    func getTrafficMessages(_ req: Request) throws -> Future<[TrafficMessage.PublicTrafficMessage]> {
        return try req.parameter(Resource.self).flatMap(to: [TrafficMessage.PublicTrafficMessage].self) { user in
            return try user.getTrafficMessages(on: req).map(to: [TrafficMessage.PublicTrafficMessage].self) { messages in
                return try messages.map({ try $0.publicTrafficMessage(upvotes: try $0.getKarmaLevel(on: req)) })
            }
        }
    }
    
    /// Returns all `CommunityMessage`s associated to a parameterized `User`.
    func getCommunityMessages(_ req: Request) throws -> Future<[CommunityMessage.PublicCommunityMessage]> {
        return try req.parameter(Resource.self).flatMap(to: [CommunityMessage.PublicCommunityMessage].self) { user in
            return try user.getCommunityMessages(on: req).map(to: [CommunityMessage.PublicCommunityMessage].self) { messages in
                return try messages.map({ try $0.publicCommunityMessage(upvotes: try $0.getKarmaLevel(on: req)) })
            }
        }
    }
    
}
