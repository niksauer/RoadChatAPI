//
//  Karmable.swift
//  App
//
//  Created by Niklas Sauer on 19.02.18.
//

import Foundation
import Vapor
import FluentSQLite

enum KarmaType: Int {
    case upvote = 1
    case neutral = 0
    case downvote = -1
}

protocol KarmaDonation: SQLiteModel, Migration, ModifiablePivot {
    var karmableID: Int { get }
    var donatorID: Int { get }
    var karma: Int { get set }
    
    func setKarmaType(_ type: KarmaType)
}

extension KarmaDonation {
    func getKarmaType() throws -> KarmaType {
        guard let karma = KarmaType(rawValue: self.karma) else {
            // invalid karma type recorded
            throw Abort(.internalServerError)
        }
        
        return karma
    }
}

protocol Karmable: SQLiteModel, Migration {
    associatedtype Donator: SQLiteModel, Migration
    associatedtype Donation: KarmaDonation
    var interactions: Siblings<Self, Donator, Donation> { get }
    
    func donate(_ karma: KarmaType, on req: Request) throws -> Future<HTTPStatus>
}

extension Karmable {
    func getKarmaLevel(on req: Request) throws -> Int {
        let upvotes = try Int(Donation.query(on: req).filter(try \Donation.karmableID == self.requireID()).filter(\Donation.karma == 1).count().await(on: req))
        let downvotes = try Int(Donation.query(on: req).filter(try \Donation.karmableID == self.requireID()).filter(\Donation.karma == -1).count().await(on: req))
        return (upvotes-downvotes)
//        return try Int(Donation.query(on: req).filter(try \Donation.karmableID == self.requireID()).sum(\Donation.karma).await(on: req))
    }
}

extension Request {
    func getInteraction<T: Karmable>(with resource: T) throws -> Future<T.Donation?> {
        return T.Donation.query(on: self).filter(try \T.Donation.donatorID == self.user().requireID()).first()
    }
}



