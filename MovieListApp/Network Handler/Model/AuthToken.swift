//
//  File.swift
//  
//
//  Created by Vaibhav Jain on 22/11/20.
//

import Foundation
// MARK: - AuthToken
struct AuthTokenResponse: Codable {
    let status: Bool
    let message: String
    let data: TokenData
    let responseTag: Int
    
    enum CodingKeys: String, CodingKey {
        case status, message, data
        case responseTag = "response_tag"
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Bool.self, forKey: .status)
        message = try container.decode(String.self, forKey: .message)
        data = try container.decode(TokenData.self, forKey: .data)
        responseTag = try (container.decodeIfPresent(Int.self, forKey: .responseTag) ?? 0)
    }
}

// MARK: - DataClass
struct TokenData: Codable {
    let accessToken, refreshToken, expires: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expires
    }
}
