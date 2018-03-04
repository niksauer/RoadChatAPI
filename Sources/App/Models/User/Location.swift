//
//  Location.swift
//  App
//
//  Created by Phillip Rust on 21.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import RoadChatKit

final class Location: Content {
    var id: Int?
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var horizontalAccuracy: Double
    var verticalAccuracy: Double
    var course: Double
    var speed: Double
    
    init(timestamp: Date, latitude: Double, longitude: Double, altitude: Double, horizontalAccuracy: Double, verticalAccuracy: Double, course: Double, speed: Double) {
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.course = course
        self.speed = speed
    }
    
    convenience init(locationRequest request: LocationRequest) {
        self.init(timestamp: request.time, latitude: request.latitude, longitude: request.longitude, altitude: request.altitude, horizontalAccuracy: request.horizontalAccuracy, verticalAccuracy: request.verticalAccuracy, course: request.course, speed: request.speed)
    }
    
    convenience init(trafficMessageRequest request: TrafficMessageRequest) {
        self.init(timestamp: request.time, latitude: request.latitude, longitude: request.longitude, altitude: request.altitude, horizontalAccuracy: request.horizontalAccuracy, verticalAccuracy: request.verticalAccuracy, course: request.course, speed: request.speed)
    }
    
    convenience init(communityMessageRequest request: CommunityMessageRequest) {
        self.init(timestamp: request.time, latitude: request.latitude, longitude: request.longitude, altitude: request.altitude, horizontalAccuracy: request.horizontalAccuracy, verticalAccuracy: request.verticalAccuracy, course: request.course, speed: request.speed)
    }
}

extension Location: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<Location, Int?> {
        return \Location.id
    }
}

