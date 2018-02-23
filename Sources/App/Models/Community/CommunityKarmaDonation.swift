//
//  CommunityKarmaDonation.swift
//  App
//
//  Created by Malcolm Malam on 21.02.18.
//

import Foundation
import Vapor
import FluentMySQL

final class CommunityKarmaDonation: Content {
    var id: Int?
    var userID: User.ID
    var communityMessageID: CommunityMessage.ID
    var karma: Int = KarmaType.neutral.rawValue
    
    init(userID: User.ID, communityMessageID: CommunityMessage.ID) {
        self.userID = userID
        self.communityMessageID = communityMessageID
    }
}

extension CommunityKarmaDonation: MySQLModel, Migration {
    static var idKey: WritableKeyPath<CommunityKarmaDonation, Int?> {
        return \CommunityKarmaDonation.id
    }
    
    static var entity: String {
        return "communityKarmaDonation"
    }
}

extension CommunityKarmaDonation: ModifiablePivot {
    typealias Left = User
    typealias Right = CommunityMessage
    
    static var leftIDKey: WritableKeyPath<CommunityKarmaDonation, Int> {
        return \CommunityKarmaDonation.userID
    }
    
    static var rightIDKey: WritableKeyPath<CommunityKarmaDonation, Int> {
        return \CommunityKarmaDonation.communityMessageID
    }
    
    convenience init(_ left: Left, _ right: Right) throws {
        try self.init(userID: left.requireID(), communityMessageID: right.requireID())
    }
}

extension CommunityKarmaDonation: KarmaDonation {
    var karmableID: Int {
        return self.communityMessageID
    }
    
    var donatorID: Int {
        return self.userID
    }
    
    func setKarmaType(_ type: KarmaType) {
        self.karma = type.rawValue
    }
}
