//
//  FacebookController.swift
//  App
//
//  Created by Niklas Sauer on 28.02.18.
//

import Foundation
import Vapor

struct OAuthURL: Content {
    let url: String
}

final class FacebookController {

    private struct FacebookDashboard {
        static let appID = "166548023972530"
        static let appSecret = "4472445261d8af94a3a9e1429c3e950c"
    }
    
    private enum Method: Hashable {
        case loginRequest
        case verifyIdentity
        case inspectToken
    }
    
    private let urlForMethod: [Method: String] = [
        .loginRequest: "https://www.facebook.com/v2.12/dialog/oauth",
        .verifyIdentity: "https://graph.facebook.com/v2.12/oauth/access_token",
        .inspectToken: "https://graph.facebook.com/debug_token"
    ]

    private func facebookURL(method: Method, parameters: [String: String]) -> URL {
        var components = URLComponents(string: urlForMethod[method]!)!
        var queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        components.queryItems = queryItems
        return components.url!
    }
    
    func loginViaFacebook(_ req: Request) throws -> Future<OAuthURL> {
        let url = facebookURL(method: .loginRequest, parameters: [
            "client_id": FacebookDashboard.appID,
            "redirect_uri": "http://localhost:8080/user/login/facebook/success",
            "state": "rwjorjwoijr",
        ])
        
        return Future(OAuthURL(url: url.absoluteString))
    }
    
    func verifyFacebookIdentity(_ req: Request) throws -> Future<HTTPStatus> {
        guard let components = URLComponents(string: req.http.uri.description), let queryItems = components.queryItems else {
            throw Abort(.internalServerError)
        }
        
        var parameters = [String: String]()
        
        for item in queryItems {
            parameters[item.name] = item.value
        }
        
        guard let code = parameters["code"], let state = parameters["state"] else {
            throw Abort(.badRequest)
        }
        
        let url = facebookURL(method: .verifyIdentity, parameters: [
            "client_id": FacebookDashboard.appID,
            "redirect_uri": "http://localhost:8080/user/login/facebook/success",
            "client_secret": FacebookDashboard.appSecret,
            "code": code
        ])
        
        let uri = URI(rawValue: url.absoluteString)!
        let hostname = uri.hostname!
        
        let client = try req.make(Client.self)
        
        let responseData = try client.get(uri, headers: [.host: hostname]).flatMap(to: Data.self) { response in
            return response.http.body.makeData(max: 1_000_000)
        }.await(on: req)
        
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
            throw Abort(.internalServerError)
        }
        
        guard let accessToken = jsonDictionary["access_token"] as? String, let duration = jsonDictionary["expires_in"] as? Int else {
            throw Abort(.badRequest)
        }
        
        try inspectAccessToken(accessToken, on: req)
        
        return Future(.ok)
    }
    
    func inspectAccessToken(_ token: String, on req: Request) throws {
        let url = facebookURL(method: .inspectToken, parameters: [
            "input_token": token,
            "access_token": "\(FacebookDashboard.appID)|\(FacebookDashboard.appSecret)"
        ])
        
        let uri = URI(rawValue: url.absoluteString)!
        let hostname = uri.hostname!
        
        let client = try req.make(Client.self)
        
        let responseData = try client.get(uri, headers: [.host: hostname]).flatMap(to: Data.self) { response in
            return response.http.body.makeData(max: 1_000_000)
        }.await(on: req)
        
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
            throw Abort(.internalServerError)
        }
        
        guard let appID = jsonDictionary["app_id"] as? String, let isValid = jsonDictionary["is_valid"] as? Bool, appID == FacebookDashboard.appID, isValid else {
            throw Abort(.unauthorized)
        }
    }
}
