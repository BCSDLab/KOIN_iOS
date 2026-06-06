//
//  ShopCountDto.swift
//  koin
//
//  Created by 홍기정 on 6/5/26.
//

import Foundation

struct ShopCountDto: Decodable {
    let totalCount: Int
    let openCount: Int

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case openCount = "open_count"
    }
}

extension ShopCountDto {
    
    func toDomain() -> ShopCount {
        return ShopCount(totalCount: totalCount, openCount: openCount)
    }
}
