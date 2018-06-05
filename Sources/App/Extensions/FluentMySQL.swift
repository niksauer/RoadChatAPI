//
//  VaporExtensions.swift
//  App
//
//  Created by Niklas Sauer on 05.04.18.
//

import Foundation
import FluentMySQL

enum MySQLError: Error {
    case noDataAvailable
}

extension URL: MySQLColumnDefinitionStaticRepresentable {
    public static var mySQLColumnDefinition: MySQLColumnDefinition {
        return .text()
    }
}

extension Data: MySQLColumnDefinitionStaticRepresentable, MySQLDataConvertible {
    public func convertToMySQLData() throws -> MySQLData {
        return MySQLData(data: self)
    }
    
    public static func convertFromMySQLData(_ mysqlData: MySQLData) throws -> Data {
        guard let data = mysqlData.data() else {
            throw MySQLError.noDataAvailable
        }
        
        return data
    }

    public static var mySQLColumnDefinition: MySQLColumnDefinition {
        return .blob(length: 1024)
    }
}
