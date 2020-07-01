//
//  RegistrationResponse.swift
//  
//
//  Created by Vaibhav Jain on 06/06/20.
//

import Foundation
// MARK: - RegistrationResponse
public struct RegistrationResponse: Codable {
    public let status: Bool
    public let message: String
    public let data: RegisterationInfo
    public let responseTag: Int

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case responseTag = "response_tag"
    }
}

// MARK: - DataClass
public struct RegisterationInfo: Codable {
    public let hotelID: String
    public let deviceID: Int
    public let keyNumber, keyID, communicationToken, wifiSSID: String
    public let wifiToken, inRoomDeviceID, roomTypeID: String
    public let viac: Int

    enum CodingKeys: String, CodingKey {
        case hotelID = "hotel_id"
        case deviceID = "device_id"
        case keyNumber = "key_number"
        case keyID = "key_id"
        case communicationToken = "communication_token"
        case wifiSSID = "wifi_ssid"
        case wifiToken = "wifi_token"
        case inRoomDeviceID = "in_room_device_id"
        case roomTypeID = "room_type_id"
        case viac = "via_c"
    }
}
