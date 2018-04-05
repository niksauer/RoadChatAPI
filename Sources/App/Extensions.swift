//
//  Extensions.swift
//  App
//
//  Created by Niklas Sauer on 05.04.18.
//

import Foundation
import FluentSQLite

enum SQLiteError: Error {
    case invalidBool
}

extension Bool: SQLiteDataConvertible {
    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> Bool {
        switch data {
        case .integer(let integer):
            let state = integer != 0 ? true : false
            return state
        default:
            throw SQLiteError.invalidBool
        }
    }
    
    public func convertToSQLiteData() throws -> SQLiteData {
        let state = self == false ? 0 : 1
        return SQLiteData.integer(state)
    }
}
