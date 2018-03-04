//
//  TrafficMessageKarmaDonation.swift
//  App
//
//  Created by Niklas Sauer on 19.02.18.
//

import Foundation
import Vapor
import FluentSQLite
import RoadChatKit

final class TrafficMessageKarmaDonation: Content {
    var id: Int?
    var trafficMessageID: TrafficMessage.ID
    var userID: User.ID
    var karma: Int = KarmaType.neutral.rawValue
    
    init(resourceID: TrafficMessage.ID, donatorID: User.ID) {
        self.trafficMessageID = resourceID
        self.userID = donatorID
    }
}

extension TrafficMessageKarmaDonation: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<TrafficMessageKarmaDonation, Int?> {
        return \TrafficMessageKarmaDonation.id
    }
}

extension TrafficMessageKarmaDonation: ModifiablePivot {
    typealias Left = TrafficMessage
    typealias Right = User
    
    static var leftIDKey: WritableKeyPath<TrafficMessageKarmaDonation, Int> {
        return \TrafficMessageKarmaDonation.trafficMessageID
    }
    
    static var rightIDKey: WritableKeyPath<TrafficMessageKarmaDonation, Int> {
        return \TrafficMessageKarmaDonation.userID
    }
    
    convenience init(_ left: Left, _ right: Right) throws {
        try self.init(resourceID: left.requireID(), donatorID: right.requireID())
    }
}

extension TrafficMessageKarmaDonation: KarmaDonation {
    var resourceID: Int {
        return self.trafficMessageID
    }
    
    var donatorID: Int {
        return self.userID
    }
}
