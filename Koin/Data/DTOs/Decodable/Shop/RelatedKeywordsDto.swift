//
//  RelatedKeywordsDto.swift
//  koin
//
//  Created by 김나훈 on 11/14/24.
//

import Foundation

struct RelatedKeywordsDto: Decodable {
    let keywords: [Keyword]?
}

struct Keyword: Decodable {
    let keyword: String
    let shopIds: [Int]?
    let shopId: Int?
    
    enum CodingKeys: String, CodingKey {
        case keyword
        case shopIds = "shop_ids"
        case shopId = "shop_id"
    }
}
