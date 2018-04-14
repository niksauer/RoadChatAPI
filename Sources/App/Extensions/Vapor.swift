//
//  VaporExtensions.swift
//  App
//
//  Created by Niklas Sauer on 05.04.18.
//

import Foundation
//import FluentSQLite
//
//enum SQLiteError: Error {
//    case invalidBool
//}
//
//extension Bool: SQLiteDataConvertible {
//    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> Bool {
//        switch data {
//        case .integer(let integer):
//            let state = integer != 0 ? true : false
//            return state
//        default:
//            throw SQLiteError.invalidBool
//        }
//    }
//    
//    public func convertToSQLiteData() throws -> SQLiteData {
//        let state = self == false ? 0 : 1
//        return SQLiteData.integer(state)
//    }
//}

import FluentMySQL

enum MySQLError: Error {
    case noDataAvailable
}

extension Data: MySQLDataConvertible {
    public func convertToMySQLData() throws -> MySQLData {
        return MySQLData(data: self)
    }

    public static func convertFromMySQLData(_ mysqlData: MySQLData) throws -> Data {
        guard let data = mysqlData.data() else {
            throw MySQLError.noDataAvailable
        }

        return data
    }
}

extension Data: MySQLColumnDefinitionStaticRepresentable {
    public static var mySQLColumnDefinition: MySQLColumnDefinition {
        return .binary(length: 100)
    }
}
