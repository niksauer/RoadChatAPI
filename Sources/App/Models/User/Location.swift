//
//  Location.swift
//  App
//
//  Created by Phillip Rust on 21.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class Location: Content {
    var id: Int?
    var userID: User.ID
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var horizontalAccuracy: Double
    var verticalAccuracy: Double
    var course: Double
    var speed: Double
    var timestamp: Date
    
    init(userID: User.ID, latitude: Double, longitude: Double, altitude: Double, horizontalAccuracy: Double, verticalAccuracy: Double, course: Double, speed: Double, timestamp: Date) {
        self.userID = userID
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.course = course
        self.speed = speed
        self.timestamp = timestamp
    }
    
    convenience init(userID: User.ID, trafficMessageRequest: TrafficMessageRequest) {
        self.init(userID: userID, latitude: trafficMessageRequest.latitude, longitude: trafficMessageRequest.longitude, altitude: trafficMessageRequest.altitude, horizontalAccuracy: trafficMessageRequest.horizontalAccuracy, verticalAccuracy: trafficMessageRequest.verticalAccuracy, course: trafficMessageRequest.course, speed: trafficMessageRequest.speed, timestamp: trafficMessageRequest.time)
    }
    
}

extension Location: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<Location, Int?> {
        return \Location.id
    }
    
    var user: Parent<Location, User> {
        return parent(\Location.userID)
    }
}

