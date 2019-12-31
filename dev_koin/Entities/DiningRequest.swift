//
//  DiningRequest.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/30.
//  Copyright © 2019 정태훈. All rights reserved.
//

import Foundation

struct DiningRequest: Codable, Hashable{
    let id: Int
    let data: String?
    let type: String?
    let place: String?
    let priceCard: Int?
    let priceCash: Int?
    let kcal: Int?
    let menu: [String]?
    private enum CodingKeys: String, CodingKey {
            case id = "id"
            case data = "data"
            case type = "type"
            case place = "place"
            case priceCard = "price_card"
            case priceCash = "price_cash"
            case kcal = "kcal"
            case menu = "menu"
    }
}
