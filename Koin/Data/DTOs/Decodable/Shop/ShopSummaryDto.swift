//
//  ShopSummaryDto.swift
//  koin
//
//  Created by 홍기정 on 9/14/25.
//

import Foundation

struct ShopSummaryDto: Decodable {
    let shopId: Int
    let name: String
    let introduction: String?
    let ratingAverage: Double
    let reviewCount: Int
    let images: [ShopImageDto]

    enum CodingKeys: String, CodingKey {
        case shopId = "shop_id"
        case name, introduction
        case ratingAverage = "rating_average"
        case reviewCount = "review_count"
        case images
    }
}
