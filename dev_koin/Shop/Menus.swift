//
//  Menus.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/15.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct Menus: Codable, Hashable {
    let shopId: Int
    let isDeleted: Bool
    let name: String
    let priceType: [PriceType]
    let id: Int
    private enum CodingKeys: String, CodingKey {
        case shopId = "shop_id"
        case isDeleted = "is_deleted"
        case name = "name"
        case priceType = "price_type"
        case id = "id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        shopId = try values.decode(Int.self, forKey: .shopId)
        isDeleted = try values.decode(Bool.self, forKey: .isDeleted)
        name = try values.decode(String.self, forKey: .name)
        id = try values.decode(Int.self, forKey: .id)
        priceType = (try? values.decode([PriceType].self, forKey: .priceType)) ?? []
    }
    
}
