//
//  NotiSubscribeDetailRequest.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//

struct NotiSubscribeDetailRequest: Encodable {
    let detailType: DetailSubscribeType
    
    enum CodingKeys: String, CodingKey {
        case detailType = "detail_type"
    }
}
