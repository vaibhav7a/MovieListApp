//
//  File.swift
//  
//
//  Created by Vaibhav Jain on 18/06/20.
//

import Foundation
public protocol EndpointManager {
    static func setApiConfig(config: ApiConfig)
}

// MARK: - APIConfig
public struct ApiConfig {
    public var baseURL: String
    public let timeout: TimeInterval
    public let isAuthorization: Bool
    public let clientID, clientSecret: String?
    public let authType: AuthGrantTypes
    public init(baseURL: String,
         timeout: TimeInterval = 60.0,
         isAuthorization: Bool = true,
         clientID: String? = nil,
         clientSecret: String? = nil,
         authType: AuthGrantTypes = .clientCredentials) {
        self.baseURL = baseURL
        self.timeout = timeout
        self.isAuthorization = isAuthorization
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.authType = authType
    }
}
