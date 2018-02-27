//
//  CommunityMessageKarmaDonation.swift
//  App
//
//  Created by Malcolm Malam on 21.02.18.
//

import Foundation
import Vapor
import FluentSQLite

final class CommunityMessageKarmaDonation: Content {
    var id: Int?
    var communityMessageID: CommunityMessage.ID
    var userID: User.ID
    var karma: Int = KarmaType.neutral.rawValue
    
    init(resourceID: CommunityMessage.ID, donatorID: User.ID) {
        self.communityMessageID = resourceID
        self.userID = donatorID
    }
}

extension CommunityMessageKarmaDonation: SQLiteModel, Migration {
    static var idKey: WritableKeyPath<CommunityMessageKarmaDonation, Int?> {
        return \CommunityMessageKarmaDonation.id
    }
}

extension CommunityMessageKarmaDonation: ModifiablePivot {
    typealias Left = CommunityMessage
    typealias Right = User
    
    static var leftIDKey: WritableKeyPath<CommunityMessageKarmaDonation, Int> {
        return \CommunityMessageKarmaDonation.communityMessageID
    }
    
    static var rightIDKey: WritableKeyPath<CommunityMessageKarmaDonation, Int> {
        return \CommunityMessageKarmaDonation.userID
    }
    
    convenience init(_ left: Left, _ right: Right) throws {
        try self.init(resourceID: left.requireID(), donatorID: right.requireID())
    }
}

extension CommunityMessageKarmaDonation: KarmaDonation {
    var resourceID: Int {
        return self.communityMessageID
    }
    
    var donatorID: Int {
        return self.userID
    }
}