//
//  ShopSummaryDTO.swift
//  koin
//
//  Created by 홍기정 on 9/14/25.
//

import Foundation

struct ShopSummaryDTO: Decodable {
    let shopId: Int
    let name: String
    let introduction: String?
    let ratingAverage, reviewCount: Int
    let images: [ShopImageDTO]

    enum CodingKeys: String, CodingKey {
        case shopId = "shop_id"
        case name, introduction
        case ratingAverage = "rating_average"
        case reviewCount = "review_count"
        case images
    }
}
