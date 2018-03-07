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

extension Location: SQLiteModel, Migration {
    public static var idKey: WritableKeyPath<Location, Int?> {
        return \Location.id
    }
}

extension Location.PublicLocation: Content {}

extension CLLocation {
    convenience init(location: Location) {
        self.init(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), altitude: location.altitude, horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, course: location.course, speed: location.speed, timestamp: location.timestamp)
    }
}

