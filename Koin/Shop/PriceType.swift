//
//  PriceType.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/15.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct PriceType: Codable, Hashable{
    let size: String
    let price: String
    private enum CodingKeys: String, CodingKey {
        case size = "size"
        case price = "price"
    }
}
