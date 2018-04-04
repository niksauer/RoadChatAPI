//
//  JSendMiddleware.swift
//  App
//
//  Created by Niklas Sauer on 07.02.18.
//

import Foundation
import Vapor

final class JSendMiddleware: Middleware, Service {
    typealias JSON = [String: Any?]
    
    struct JSendResponse {
        let status: HTTPStatus
        let body: String
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        let promise = request.eventLoop.newPromise(Response.self)
        
        func handleError(_ error: Error) {
            let response: JSendResponse
            
            switch error {
            case let fail as APIFail:
                response = JSendMiddleware.fail(fail)
            default:
                response = JSendMiddleware.error(error)
            }

            let res = request.makeResponse()
            res.http.body = HTTPBody(string: response.body)
            res.http.status = response.status
            promise.succeed(result: res)
        }
        
        do {
            try next.respond(to: request).do { res in
                promise.succeed(result: JSendMiddleware.success(res))
            }.catch { error in
                handleError(error)
            }
        } catch {
            handleError(error)
        }
        
        return promise.futureResult
    }
    
    static func success(_ response: Response) -> Response {
        do {
            guard let byteCount = response.http.body.count else {
                throw Abort(.internalServerError)
            }
            
            guard byteCount > 0 else {
                let result: JSON = [
                    "status": "success",
                    "data": nil
                ]
                
                try response.content.encode(getJSONString(for: result))
                
                return response
            }
            
            let data = try response.http.body.consumeData(max: byteCount, on: response).wait()

            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                throw Abort(.internalServerError)
            }

            let result: JSON = [
                "status": "success",
                "data": json
            ]

            try response.content.encode(getJSONString(for: result))

            return response
        } catch {
            let result: JSON = [
                "status": "error",
                "message": "Error converting response to JSend success format."
            ]
            
            do {
                try response.content.encode(getJSONString(for: result))
            } catch {
                // handle error
            }
            
            response.http.status = .internalServerError
    
            return response
        }
    }
    
    static func fail(_ fail: APIFail) -> JSendResponse {
        let result: JSON = [
            "status": "fail",
            "data": fail.message
        ]
        
        return JSendResponse(status: .badRequest, body: getJSONString(for: result))
    }
    
    static func error(_ error: Error) -> JSendResponse {
        let result: JSON = [
            "status": "error",
            "message": error.localizedDescription
        ]
        
        return JSendResponse(status: .internalServerError, body: getJSONString(for: result))
    }
    
    private static func getJSONString(for json: JSON) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
}
