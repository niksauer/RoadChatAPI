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
    
    private let uploadDirectory: URL
    
    init(uploadDirectory: URL) {
        self.uploadDirectory = uploadDirectory
    }
    
    /// Saves a new `User` to the database.
    func create(_ req: Request) throws -> Future<Result> {
        return try RegisterRequest.extract(from: req).flatMap(to: Result.self) { registerRequest in
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
                    
                    let hasher = try req.make(BCryptDigest.self)
                    let hashedPassword = try hasher.hash(registerRequest.password, cost: hashingCost)
                    
                    let newUser = User(email: registerRequest.email, username: registerRequest.username, password: hashedPassword)
                    
                    return newUser.create(on: req).flatMap(to: Result.self) { user in
                        // default user setup
                        return Settings(userID: try user.requireID()).create(on: req).flatMap(to: Result.self) { _ in
                            return Privacy(userID: try user.requireID()).create(on: req).flatMap(to: Result.self) { _ in
                                return try newUser.publicUser(on: req)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Returns a parameterized `User`.
    func get(_ req: Request) throws -> Future<Result> {
        return try req.parameters.next(Resource.self).flatMap(to: Result.self) { user in
            return try user.publicUser(on: req)
        }
    }
    
    /// Updates a parameterized `User`.
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Resource.self).flatMap(to: HTTPStatus.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try UserRequest.extract(from: req).flatMap(to: HTTPStatus.self) { updatedUser in
                if let email = updatedUser.email {
                    user.email = email
                }
                
                if let username = updatedUser.username {
                    user.username = username
                }
                
                if let password = updatedUser.password {
                    let hasher = try req.make(BCryptDigest.self)
                    let hashedPassword = try hasher.hash(password, cost: hashingCost)
                    user.password = hashedPassword
                }
        
                return user.update(on: req).transform(to: .ok)
            }
        }
    }
    
    /// Deletes a parameterized `User`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Resource.self).flatMap(to: HTTPStatus.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            // delete requested user and all of his associated resources and participations in chat
            return try user.authTokens.query(on: req).delete().flatMap(to: HTTPStatus.self) { _ in
                return try user.settings.query(on: req).delete().flatMap(to: HTTPStatus.self) { _ in
                    return try user.privacy.query(on: req).delete().flatMap(to: HTTPStatus.self) { _ in
                        return try user.profile.query(on: req).delete().flatMap(to: HTTPStatus.self) { _ in
                            return try user.cars.query(on: req).delete().flatMap(to: HTTPStatus.self) { _ in
                                return Participation.query(on: req).filter(try \Participation.userID == user.requireID()).delete().flatMap(to: HTTPStatus.self) { _ in
                                    return user.delete(on: req).transform(to: .ok)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Returns the `Setting`s for a parameterized `User`.
    func getSettings(_ req: Request) throws -> Future<Settings.PublicSettings> {
        return try req.parameters.next(Resource.self).flatMap(to: Settings.PublicSettings.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try user.getSettings(on: req).map(to: Settings.PublicSettings.self) { settings in
                return settings.publicSettings()
            }
        }
    }
    
    /// Updates the `Setting`s for a parameterized `User`.
    func updateSettings(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Resource.self).flatMap(to: HTTPStatus.self) { user in
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
        return try req.parameters.next(Resource.self).flatMap(to: Privacy.PublicPrivacy.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try user.getPrivacy(on: req).map(to: Privacy.PublicPrivacy.self) { privacy in
                return privacy.publicPrivacy()
            }
        }
    }
    
    /// Updates the `Privacy` for a parameterized `User`.
    func updatePrivacy(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Resource.self).flatMap(to: HTTPStatus.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try PrivacyRequest.extract(from: req).flatMap(to: HTTPStatus.self) { updatedPrivacy in
                return try user.getPrivacy(on: req).flatMap(to: HTTPStatus.self) { privacy in
                    privacy.shareLocation = updatedPrivacy.shareLocation
                    privacy.showEmail = updatedPrivacy.showEmail
                    privacy.showFirstName = updatedPrivacy.showFirstName
                    privacy.showLastName = updatedPrivacy.showLastName
                    privacy.showBirth = updatedPrivacy.showBirth
                    privacy.showSex = updatedPrivacy.showSex
                    privacy.showBiography = updatedPrivacy.showBiography
                    privacy.showStreet = updatedPrivacy.showStreet
                    privacy.showCity = updatedPrivacy.showCity
                    privacy.showCountry = updatedPrivacy.showCountry
                    
                    return privacy.update(on: req).transform(to: .ok)
                }
            }
        }
    }
    
    /// Returns the `Profile` for a parameterized `User`.
    func getProfile(_ req: Request) throws -> Future<Profile.PublicProfile> {
        return try req.parameters.next(Resource.self).flatMap(to: Profile.PublicProfile.self) { user in
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
        return try req.parameters.next(Resource.self).flatMap(to: HTTPStatus.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try ProfileRequest.extract(from: req).flatMap(to: HTTPStatus.self) { profileRequest in
                return try user.getProfile(on: req).flatMap(to: HTTPStatus.self) { existingProfile in
                    guard let profile = existingProfile else {
                        let newProfile = try Profile(userID: try user.requireID(), profileRequest: profileRequest)
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
                    profile.city = profileRequest.city
                    profile.country = profileRequest.country
                    
                    return profile.update(on: req).transform(to: .ok)
                }
            }
        }
    }

    /// Returns all `Cars`s associated to a parameterized `User`.
    func getCars(_ req: Request) throws -> Future<[Car.PublicCar]> {
        return try req.parameters.next(Resource.self).flatMap(to: [Car.PublicCar].self) { user in
            return try user.getCars(on: req).map(to: [Car.PublicCar].self) { cars in
                return try cars.map({ try $0.publicCar() })
            }
        }
    }

    /// Saves a new `Car` to the database which is associated to a parameterized `User`.
    func createCar(_ req: Request) throws -> Future<Car.PublicCar> {
        return try req.parameters.next(Resource.self).flatMap(to: Car.PublicCar.self) { user in
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
        return try req.parameters.next(Resource.self).flatMap(to: Location.PublicLocation.self) { user in
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
        return try req.parameters.next(Resource.self).flatMap(to: HTTPStatus.self) { user in
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
        return try req.parameters.next(Resource.self).flatMap(to: [TrafficMessage.PublicTrafficMessage].self) { user in
            return try user.getTrafficMessages(on: req).flatMap(to: [TrafficMessage.PublicTrafficMessage].self) { messages in
                return try messages.map {
                    return try $0.publicTrafficMessage(on: req)
                }.map(to: [TrafficMessage.PublicTrafficMessage].self, on: req) { publicMessages in
                    return publicMessages
                }
            }
        }
    }

    /// Returns all `CommunityMessage`s associated to a parameterized `User`.
    func getCommunityMessages(_ req: Request) throws -> Future<[CommunityMessage.PublicCommunityMessage]> {
        return try req.parameters.next(Resource.self).flatMap(to: [CommunityMessage.PublicCommunityMessage].self) { user in
            return try user.getCommunityMessages(on: req).flatMap(to: [CommunityMessage.PublicCommunityMessage].self) { messages in
                return try messages.map {
                    return try $0.publicCommunityMessage(on: req)
                }.map(to: [CommunityMessage.PublicCommunityMessage].self, on: req) { publicMessages in
                    return publicMessages
                }
            }
        }
    }

    func getImage(_ req: Request) throws -> Future<PublicFile> {
        return try req.parameters.next(Resource.self).map(to: PublicFile.self) { car in
            let fileManager = FileManager()
            let filename = "user\(try car.requireID()).jpg"
            let url = self.uploadDirectory.appendingPathComponent(filename)
            
            guard let data = fileManager.contents(atPath: url.path) else {
                throw Abort(.notFound)
            }
            
            return PublicFile(filename: filename, data: data)
        }
    }
    
    func uploadImage(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Resource.self).flatMap(to: HTTPStatus.self) { user in
            try req.user().checkOwnership(for: user, on: req)
            
            return try req.content.decode(Multipart.self).map(to: HTTPStatus.self) { image in
                let acceptableTypes = [MediaType.jpeg]
                
                guard let mimeType = image.file.contentType, acceptableTypes.contains(mimeType) else {
                    throw Abort(.badRequest)
                }
                
                let url = self.uploadDirectory.appendingPathComponent("user\(try user.requireID()).jpg")
                _ = try image.file.data.write(to: url)
                
                return .ok
            }
        }
    }
    
}

