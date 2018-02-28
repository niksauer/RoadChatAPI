//
//  FacebookController.swift
//  App
//
//  Created by Niklas Sauer on 28.02.18.
//

import Foundation
import Vapor

import Async
import Bits
import HTTP
import TCP
import TLS

#if os(Linux)
import OpenSSL
#else
import AppleTLS
#endif

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
    }
    
    private let urlForMethod: [Method: String] = [
        .loginRequest: "https://www.facebook.com/v2.12/dialog/oauth",
        .verifyIdentity: "https://graph.facebook.com/v2.12/oauth/access_token"
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
            throw Abort(.internalServerError)
        }
        
        let url = facebookURL(method: .verifyIdentity, parameters: [
            "client_id": FacebookDashboard.appID,
            "redirect_uri": "http://localhost:8080/user/login/facebook/success",
            "client_secret": FacebookDashboard.appSecret,
            "code": code
        ])
        
        let uri = URI(rawValue: url.absoluteString)!
        let hostname = uri.hostname!
        
//        let eventLoop = try DefaultEventLoop(label: "api.roadchat.facebook")
//        let tcpSocket = try TCPSocket(isNonBlocking: true)
//        let tcpClient = try TCPClient(socket: tcpSocket)
//
//        var settings = TLSClientSettings()
//        settings.peerDomainName = hostname
//
//        #if os(macOS)
//        let tlsClient = try AppleTLSClient(tcp: tcpClient, using: settings)
//        #else
//        let tlsClient = try OpenSSLClient(tcp: tcpClient, using: settings)
//        #endif
//
//        try tlsClient.connect(hostname: hostname, port: 80)
//
//        let client = HTTPClient(stream: tlsClient.socket.stream(on: eventLoop), on: eventLoop)
//        let request = HTTPRequest(method: .get, uri: uri, headers: [.host: hostname])
        
        let client = try HTTPClient.tcp(hostname: hostname, port: 80, on: req, onError: { _ , error in })
        let request = HTTPRequest(method: .get, uri: uri, headers: [.host: hostname])
        
        let responseData = try client.send(request).flatMap(to: Data.self) { res in
            return res.body.makeData(max: 1_000_000)
        }.await(on: req)
        
        guard let responseString = String(data: responseData, encoding: .utf8) else {
            throw Abort(.internalServerError)
        }
    
        
//        guard let jsonDictionary = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
//            throw Abort(.internalServerError)
//        }
        
//        print(responseString)
        
//        struct AccessToken: Codable {
//            let access_token: String
//            let token_type: String
//            let expires_in: Int
//        }
//
//        response.body.
//        print(response.)
        
        return Future(.ok)
    }
}
