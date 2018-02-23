//
//  TrafficKarmaDonation.swift
//  App
//
//  Created by Niklas Sauer on 19.02.18.
//

import Foundation
import Vapor
import FluentMySQL

final class TrafficKarmaDonation: Content {
    var id: Int?
    var userID: User.ID
    var trafficMessageID: TrafficMessage.ID
    var karma: Int = KarmaType.neutral.rawValue
    
    init(userID: User.ID, trafficMessageID: TrafficMessage.ID) {
        self.userID = userID
        self.trafficMessageID = trafficMessageID
    }
}

extension TrafficKarmaDonation: MySQLModel, Migration {
    static var idKey: WritableKeyPath<TrafficKarmaDonation, Int?> {
        return \TrafficKarmaDonation.id
    }
    
    static var entity: String {
        return "trafficKarmaDonation"
    }
}

extension TrafficKarmaDonation: ModifiablePivot {
    typealias Left = User
    typealias Right = TrafficMessage
    
    static var leftIDKey: WritableKeyPath<TrafficKarmaDonation, Int> {
        return \TrafficKarmaDonation.userID
    }
    
    static var rightIDKey: WritableKeyPath<TrafficKarmaDonation, Int> {
        return \TrafficKarmaDonation.trafficMessageID
    }
    
    convenience init(_ left: User, _ right: TrafficMessage) throws {
        try self.init(userID: left.requireID(), trafficMessageID: right.requireID())
    }
}

extension TrafficKarmaDonation: KarmaDonation {
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
