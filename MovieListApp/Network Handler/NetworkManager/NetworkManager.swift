//
//  NetworkManager.swift
//  APIManager
//
//  Created by Vaibhav Jain on 02/06/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

public struct NetworkManager {
    static  let ServiceRouter = Router<AuthApi>()
    static func generateToken(completion: @escaping (Result<AuthTokenResponse?, APIError>) -> Void) {
        ServiceRouter.fetch(.generateToken, decode: { json -> AuthTokenResponse? in
            guard let result = json as? AuthTokenResponse else { return  nil }
            return result
        }, completion: completion)
    }
    
    static func refreshToken(completion: @escaping (Result<AuthTokenResponse?, APIError>) -> Void) {
        ServiceRouter.fetch(.refreshToken, decode: { json -> AuthTokenResponse? in
            guard let result = json as? AuthTokenResponse else { return  nil }
            return result
        }, completion: completion)
    }
    
    public static func clearToken() {
       UserDefaults.standard.setValue(nil, forKey: "AuthApi_clientID")
        UserDefaults.standard.setValue(nil, forKey: "AuthApi_clientSecret")
        UserDefaults.standard.set(nil, forKey: "AccessToken")
    }
}


extension NetworkManager: EndpointManager {
    public static func setApiConfig(config: ApiConfig) {
        NetworkManager.baseURL = config.baseURL
        NetworkManager.timeout = config.timeout
        NetworkManager.isAuthorization = config.isAuthorization
        NetworkManager.clientID = config.clientID
        NetworkManager.clientSecret = config.clientSecret
        NetworkManager.authGrantType = config.authType
        if config.authType == .passwordGrant {
            UserDefaults.standard.set(clientID, forKey: "AccessToken")
        }
    }
    
    static var baseURL: String {
        get {
            return UserDefaults.standard.string(forKey: "AuthApi_BaseURL") ?? ""
        }
        set(urlStr) {
            UserDefaults.standard.setValue(urlStr, forKey: "AuthApi_BaseURL")
        }
    }
    
    static var clientID: String? {
        get {
            return UserDefaults.standard.string(forKey: "AuthApi_clientID")
        }
        set(clientID) {
            UserDefaults.standard.setValue(clientID, forKey: "AuthApi_clientID")
        }
    }
    
    static var clientSecret: String? {
        get {
            return UserDefaults.standard.string(forKey: "AuthApi_clientSecret")
        }
        set(secret) {
            UserDefaults.standard.setValue(secret, forKey: "AuthApi_clientSecret")
        }
    }
    
    static var timeout: TimeInterval {
        get {
            let timeoutConfig = UserDefaults.standard.double(forKey: "AuthApi_Timeout")
            if timeoutConfig == 0 {
                return 60.0
            }
            return timeoutConfig
        }
        set(timeoutConfig) {
            UserDefaults.standard.setValue(timeoutConfig, forKey: "AuthApi_Timeout")
        }
    }
    
    static var isAuthorization: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "AuthApi_Authorization")
        }
        set(isAuthorized) {
            UserDefaults.standard.setValue(isAuthorized, forKey: "AuthApi_Authorization")
        }
    }
    
    static var authGrantType: AuthGrantTypes {
        get {
            let authType = UserDefaults.standard.integer(forKey: "AuthApi_AuthGrantType")
            return AuthGrantTypes(rawValue: authType) ?? AuthGrantTypes.clientCredentials
        }
        set(authType) {
            UserDefaults.standard.set(authType.rawValue, forKey: "AuthApi_AuthGrantType")
        }
    }
}
