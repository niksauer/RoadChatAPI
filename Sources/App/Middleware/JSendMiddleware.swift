//
//  ErrorMiddleware.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor

enum APIFail: Error {
    case invalidRegisterRequest
    case invalidLoginRequest
}

final class JSendMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        do {
            return try next.respond(to: request).map(to: Response.self) { response in
                // sucess
                // use data or null as payload
                return response
            }
        } catch is APIFail {
            // fail 
            // use details mapped to error as payload
            throw Abort(.badRequest)
        } catch {
            // error
            // use received details as payload
            throw Abort(.internalServerError)
        }
    }
}
