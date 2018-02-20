//
//  TrafficKarma.swift
//  App
//
//  Created by Niklas Sauer on 19.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class TrafficKarma: Content {
    var id: Int?
    var userID: User.ID
    var trafficMessageID: TrafficMessage.ID
    var karma: Int = KarmaType.neutral.rawValue
    
    init(userID: User.ID, trafficMessageID: TrafficMessage.ID) {
        self.userID = userID
        self.trafficMessageID = trafficMessageID
    }
}

extension TrafficKarma: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<TrafficKarma, Int?> {
        return \TrafficKarma.id
    }
}

extension TrafficKarma: ModifiablePivot {
    typealias Left = User
    typealias Right = TrafficMessage
    
    static var leftIDKey: ReferenceWritableKeyPath<TrafficKarma, Int> {
        return \TrafficKarma.userID
    }

    static var rightIDKey: ReferenceWritableKeyPath<TrafficKarma, Int> {
        return \TrafficKarma.trafficMessageID
    }
    
    convenience init(_ left: TrafficKarma.Left, _ right: TrafficKarma.Right) throws {
        try self.init(userID: left.requireID(), trafficMessageID: right.requireID())
    }
}

extension TrafficKarma: KarmaDonation {
    var karmableID: Int {
        return self.trafficMessageID
    }
    
    var donatorID: Int {
        return self.userID
    }
    
    func setKarmaType(_ type: KarmaType) {
        self.karma = type.rawValue
    }
}
