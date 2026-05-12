//
//  SendDeviceTokenRequest.swift
//  koin
//
//  Created by 김나훈 on 7/30/24.
//

struct SendDeviceTokenRequest: Encodable {
    let deviceToken: String
    
    enum CodingKeys: String, CodingKey {
        case deviceToken = "device_token"
    }
}
