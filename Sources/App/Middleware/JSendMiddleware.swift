//
//  JSendMiddleware.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor

final class JSendMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        do {
            return try next.respond(to: request).flatMap(to: Response.self) { response in
                // sucess
                // use data or null as payload
                return try JSendManager.success(response)
            }
        } catch {
            switch error {
            case let fail as APIFail:
                // fail
                // use details mapped to error as payload
                return try JSendManager.fail(type: fail, using: request.superContainer)
            default:
                // error
                // use received details as payload
                throw Abort(.internalServerError)
            }
        }
    }
}

struct JSendManager {
    typealias JSON = [String: Any?]
    
    static func success(_ response: Response) throws -> Future<Response> {
        guard let byteCount = response.http.body.count else {
            throw Abort(.internalServerError)
        }
        
        guard byteCount > 0 else {
            let result: JSON = [
                "status": "success",
                "data": nil
            ]
            
            try response.content.encode(getJSONString(for: result))
            
            return Future(response)
        }
        
        return response.http.body.makeData(max: byteCount).map(to: Response.self) { data in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                throw Abort(.internalServerError)
            }
            
            let result: JSON = [
                "status": "success",
                "data": json
            ]
            
            try response.content.encode(getJSONString(for: result))
            
            return response
        }
    }
    
    static func fail(type fail: APIFail, using container: Container) throws -> Future<Response> {
        let result: JSON = [
            "status": "fail",
            "data": fail.message
        ]
        
        let response = try Response(http: HTTPResponse(body: getJSONString(for: result)), using: container)
        response.http.status = .badRequest
        
        return Future(response)
    }
    
    private static func getJSONString(for json: JSON) throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw Abort(.internalServerError)
        }
        
        return jsonString
    }
}
