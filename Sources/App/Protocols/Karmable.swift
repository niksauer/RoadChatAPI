//
//  Karmable.swift
//  App
//
//  Created by Niklas Sauer on 19.02.18.
//

import Foundation
import Vapor
import FluentMySQL

enum KarmaType: Int {
    case upvote = 1
    case neutral = 0
    case downvote = -1
}

protocol KarmaDonation: MySQLModel, Migration, ModifiablePivot {
    var resourceID: Int { get }
    var donatorID: Int { get }
    var karma: Int { get set }

    init(resourceID: Int, donatorID: Int)
}

extension KarmaDonation {
    func getKarmaType() throws -> KarmaType {
        guard let karma = KarmaType(rawValue: self.karma) else {
            // invalid karma type recorded
            throw Abort(.internalServerError)
        }
        
        return karma
    }
    
    mutating func setKarmaType(_ type: KarmaType) {
        self.karma = type.rawValue
    }
}

protocol KarmaDonator: MySQLModel, Migration { }

extension KarmaDonator {
    func getDonation<T: Karmable>(for resource: T, on req: Request) throws -> Future<T.Donation?> {
        return T.Donation.query(on: req).filter(try \T.Donation.donatorID == self.requireID()).first()
    }
    
    func donate<T: Karmable>(_ karma: KarmaType, to resource: T, on req: Request) throws -> Future<HTTPStatus> {
        return try self.getDonation(for: resource, on: req).flatMap(to: HTTPStatus.self) { donation in
            guard var donation = donation else {
                var donation = try T.Donation(resourceID: resource.requireID(), donatorID: self.requireID())
                donation.karma = karma.rawValue
                
                return donation.save(on: req).transform(to: .ok)
            }
            
            let currentKarma = try donation.getKarmaType()
            
            if karma == .upvote {
                switch currentKarma {
                case .upvote:
                    donation.karma = KarmaType.neutral.rawValue
                case .neutral:
                    donation.karma = KarmaType.upvote.rawValue
                case .downvote:
                    donation.karma = KarmaType.upvote.rawValue
                }
            } else {
                switch currentKarma {
                case .upvote:
                    donation.karma = KarmaType.downvote.rawValue
                case .neutral:
                    donation.karma = KarmaType.downvote.rawValue
                case .downvote:
                    donation.karma = KarmaType.neutral.rawValue
                }
            }

            return donation.save(on: req).transform(to: HTTPStatus.ok)
        }
    }
}

protocol Karmable: MySQLModel, Migration {
    associatedtype Donator: KarmaDonator
    associatedtype Donation: KarmaDonation
    var donations: Siblings<Self, Donator, Donation> { get }
}

extension Karmable {
    func getKarmaLevel(on req: Request) throws -> Future<Int> {
        return Donation.query(on: req).filter(try \Donation.resourceID == self.requireID()).filter(\Donation.karma == 1).count().flatMap(to: Int.self) { upvotes in
            return Donation.query(on: req).filter(try \Donation.resourceID == self.requireID()).filter(\Donation.karma == -1).count().map(to: Int.self) { downvotes in
                return (upvotes-downvotes)
            }
        }
        
//        return try Int(Donation.query(on: req).filter(try \Donation.karmableID == self.requireID()).sum(\Donation.karma).await(on: req))
    }
}
