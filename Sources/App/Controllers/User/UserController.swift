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
import RoadChatKit

/// Controls basic CRUD operations on `User`s.
final class UserController {
    
    typealias Resource = User
    typealias Result = User.PublicUser
    
    /// Saves a new `User` to the database.
    func create(_ req: Request) throws -> Future<Result> {
        return try RegisterRequest.extract(from: req).flatMap(to: Result.self) { registerRequest in
            return try User.query(on: req).filter(\User.email == registerRequest.email).first().flatMap(to: Result.self) { existingUser in
                guard existingUser == nil else {
                    // email already registered
                    throw RegisterFail.emailTaken
                }
                
                return try User.query(on: req).filter(\User.username == registerRequest.username).first().flatMap(to: Result.self) { existingUser in
                    guard existingUser == nil else {
                        // username taken
                        throw RegisterFail.usernameTaken
                    }
                    
                    let hasher = try req.make(BCryptDigest.self)
                    let hashedPassword = try hasher.hash(registerRequest.password, cost: hashingCost)
                    
                    let newUser = User(email: registerRequest.email, username: registerRequest.username, password: hashedPassword)
                    
                    return newUser.create(on: req).flatMap(to: Result.self) { user in
                        // default user setup
                        return Settings(userID: try user.requireID()).create(on: req).flatMap(to: Result.self) { _ in
                            return Privacy(userID: try user.requireID()).create(on: req).map(to: Result.self) { _ in
                                return try newUser.publicUser(isOwner: true)
                            }
                        }
                    }
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
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try RegisterRequest.extract(from: req).flatMap(to: HTTPStatus.self) { updatedUser in
                let hasher = try req.make(BCryptDigest.self)
                let hashedPassword = try hasher.hash(updatedUser.password, cost: hashingCost)
                
                user.email = updatedUser.email
                user.username = updatedUser.username
                user.password = hashedPassword
                
                return user.update(on: req).transform(to: .ok)
            }
        }
    }
    
    /// Deletes a parameterized `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            // delete requested user and all of his associated resources and participations in chat
            _ = try user.authTokens.query(on: req).delete()
            _ = try user.settings.query(on: req).delete()
            _ = try user.privacy.query(on: req).delete()
            _ = try user.profile.query(on: req).delete()
            _ = try user.cars.query(on: req).delete()
            _ = Participation.query(on: req).filter(try \Participation.userID == user.requireID()).delete()
            
            return user.delete(on: req).transform(to: .ok)
        }
    }
    
    /// Returns the `Setting`s for a parameterized `User`.
    func getSettings(_ req: Request) throws -> Future<Settings.PublicSettings> {
        return try req.parameter(Resource.self).flatMap(to: Settings.PublicSettings.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try user.getSettings(on: req).map(to: Settings.PublicSettings.self) { settings in
                return settings.publicSettings()
            }
        }
    }
    
    /// Updates the `Setting`s for a parameterized `User`.
    func updateSettings(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try SettingsRequest.extract(from: req).flatMap(to: HTTPStatus.self) { updatedSettings in
                return try user.getSettings(on: req).flatMap(to: HTTPStatus.self) { settings in
                    settings.communityRadius = updatedSettings.communityRadius
                    settings.trafficRadius = updatedSettings.trafficRadius
                    
                    return settings.update(on: req).transform(to: .ok)
                }
            }
        }  
    }
    
    /// Returns the `Privacy` for a parameterized `User`.
    func getPrivacy(_ req: Request) throws -> Future<Privacy.PublicPrivacy> {
        return try req.parameter(Resource.self).flatMap(to: Privacy.PublicPrivacy.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try user.getPrivacy(on: req).map(to: Privacy.PublicPrivacy.self) { privacy in
                return privacy.publicPrivacy()
            }
        }
    }
    
    /// Updates the `Privacy` for a parameterized `User`.
    func updatePrivacy(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try PrivacyRequest.extract(from: req).flatMap(to: HTTPStatus.self) { updatedPrivacy in
                return try user.getPrivacy(on: req).flatMap(to: HTTPStatus.self) { privacy in
                    privacy.showFirstName = updatedPrivacy.showFirstName
                    privacy.showLastName = updatedPrivacy.showLastName
                    privacy.showBirth = updatedPrivacy.showBirth
                    privacy.showSex = updatedPrivacy.showSex
                    privacy.showAddress = updatedPrivacy.showAddress
                    privacy.showBiography = updatedPrivacy.showBiography
                    
                    return privacy.update(on: req).transform(to: .ok)
                }
            }
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
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try ProfileRequest.extract(from: req).flatMap(to: HTTPStatus.self) { profileRequest in
                return try user.getProfile(on: req).flatMap(to: HTTPStatus.self) { existingProfile in
                    guard let profile = existingProfile else {
                        let newProfile = Profile(userID: try user.requireID(), profileRequest: profileRequest)
                        return newProfile.create(on: req).transform(to: .created)
                    }
                    
                    profile.firstName = profileRequest.firstName
                    profile.lastName = profileRequest.lastName
                    profile.birth = profileRequest.birth
                    profile.sex = profileRequest.sex
                    profile.biography = profileRequest.biography
                    profile.streetName = profileRequest.streetName
                    profile.streetNumber = profileRequest.streetNumber
                    profile.postalCode = profileRequest.postalCode
                    profile.country = profileRequest.country
                    
                    return profile.update(on: req).transform(to: .ok)
                }
            }
        }
    }
    
    /// Returns all `Cars`s associated to a parameterized `User`.
    func getCars(_ req: Request) throws -> Future<[Car.PublicCar]> {
        return try req.parameter(Resource.self).flatMap(to: [Car.PublicCar].self) { user in
            return try user.getCars(on: req).map(to: [Car.PublicCar].self) { cars in
                return try cars.map({ try $0.publicCar() })
            }
        }
    }
    
    /// Saves a new `Car` to the database which is associated to a parameterized `User`.
    func createCar(_ req: Request) throws -> Future<Car.PublicCar> {
        return try req.parameter(Resource.self).flatMap(to: Car.PublicCar.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try CarRequest.extract(from: req).flatMap(to: Car.PublicCar.self) { carRequest in
                return Car(userID: try user.requireID(), carRequest: carRequest).create(on: req).map(to: Car.PublicCar.self) { car in
                    return try car.publicCar()
                }
            }
        }
    }
    
    /// Returns the `Location` for a parameterized `User`.
    func getLocation(_ req: Request) throws -> Future<Location.PublicLocation> {
        return try req.parameter(Resource.self).flatMap(to: Location.PublicLocation.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try user.getLocation(on: req).map(to: Location.PublicLocation.self) { location in
                guard let location = location else {
                    // no location associated to user
                    throw Abort(.notFound)
                }
                
                return location.publicLocation()
            }
        }
    }
    
    /// Creates or updates the `Location` for a parameterized `User`.
    func createOrUpdateLocation(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameter(Resource.self).flatMap(to: HTTPStatus.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try LocationRequest.extract(from: req).flatMap(to: HTTPStatus.self) { locationRequest in
                return try user.getLocation(on: req).flatMap(to: HTTPStatus.self) { existingLocation in
                    guard let location = existingLocation else {
                        let newLocation = Location(locationRequest: locationRequest)
                        return newLocation.create(on: req).flatMap(to: HTTPStatus.self) { location in
                            user.locationID = try location.requireID()
                            return user.save(on: req).transform(to: HTTPStatus.ok)
                        }
                    }
                    
                    location.latitude = locationRequest.latitude
                    location.longitude = locationRequest.longitude
                    location.altitude = locationRequest.altitude
                    location.horizontalAccuracy = locationRequest.horizontalAccuracy
                    location.verticalAccuracy = locationRequest.verticalAccuracy
                    location.course = locationRequest.course
                    location.speed = locationRequest.speed
                    location.timestamp = locationRequest.time
                    
                    return location.update(on: req).transform(to: .ok)
                }
            }
        }
    }
    
    /// Returns all `TrafficMessage`s associated to a parameterized `User`.
    func getTrafficMessages(_ req: Request) throws -> Future<[TrafficMessage.PublicTrafficMessage]> {
        return try req.parameter(Resource.self).flatMap(to: [TrafficMessage.PublicTrafficMessage].self) { user in
            return try user.getTrafficMessages(on: req).flatMap(to: [TrafficMessage.PublicTrafficMessage].self) { messages in
                return try messages.map {
                    return try $0.publicTrafficMessage(on: req)
                }.map(to: [TrafficMessage.PublicTrafficMessage].self, on: req) { publicMesages in
                    return publicMesages
                }
            }
        }
    }
    
    /// Returns all `CommunityMessage`s associated to a parameterized `User`.
    func getCommunityMessages(_ req: Request) throws -> Future<[CommunityMessage.PublicCommunityMessage]> {
        return try req.parameter(Resource.self).flatMap(to: [CommunityMessage.PublicCommunityMessage].self) { user in
            return try user.getCommunityMessages(on: req).flatMap(to: [CommunityMessage.PublicCommunityMessage].self) { messages in
                return try messages.map {
                    return try $0.publicCommunityMessage(on: req)
                }.map(to: [CommunityMessage.PublicCommunityMessage].self, on: req) { publicMesages in
                    return publicMesages
                }
            }
        }
    }
    
}
