//
//  OrderTrackingDTO.swift
//  koin
//
//  Created by 이은지 on 9/8/25.
//

import Foundation

// TODO: - API 나오면 수정
struct OrderTrackingDTO: Decodable {
    let shopName: String
    let orderType: String
    let orderStatus: String
    let expectedAt: String?
}
