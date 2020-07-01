//
//  AuthEndPoint.swift
//
//
//  Created by Vaibhav Jain on 21/11/20.
//

import Foundation

public enum AuthApi {
    case generateToken
    case refreshToken
}

extension AuthApi: EndPointType {
    var clientID: String {
        guard let clientID = NetworkManager.clientID else { fatalError("clientID could not be configured.")}
        return clientID
    }
    
    var clientSecret: String {
        guard let secret = NetworkManager.clientSecret else { fatalError("clientSecret could not be configured.")}
        return secret
    }
    
    public var isAuthorization: Bool {
        return NetworkManager.isAuthorization
    }
    
    public var baseURL: URL {
        guard let url = URL(string: NetworkManager.baseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    public var path: String {
        switch self {
        case .generateToken:
            return "client/getToken"
        case .refreshToken:
            return "get-access-token"
        }
    }
    
    public var httpMethod: HTTPMethod {
        switch self {
        case .generateToken:
             return .post
        case .refreshToken:
            return .put
        }
       
    }
    
    public var task: HTTPTask {
        switch self {
        case .generateToken:
            return .requestParameters(bodyParameters: ["client_id":clientID,
                                                       "client_secret":clientSecret],
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .refreshToken:
            return .requestParameters(bodyParameters: ["auth_token":clientID,
                             "refresh_token":clientSecret],
            bodyEncoding: .jsonEncoding,
            urlParameters: nil)
        }
    }
    
    public var headers: HTTPHeaders? {
        switch self {
        case .generateToken:
             return nil
        case .refreshToken:
            return ["Content-Type":"application/json",
                    "Accept":"application/vnd.Apple.v1+json"]
        }
    }
    
    public var timeout: TimeInterval {
        return NetworkManager.timeout
    }
}


