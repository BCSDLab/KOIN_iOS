//
//  Store.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/15.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct Store: Codable, Hashable, Identifiable {
    let delivery: Bool
    let address: String?
    let payCard: Bool
    let description: String?
    let imageUrls: [String]?
    let openTime: String?
    let closeTime: String?
    let isEvent: Bool
    let eventArticles: [StoreEvent]?
    let payBank: Bool
    let hit: Int
    let internalName: String
    let isDeleted: Bool
    let phone: String?
    let chosung: String
    let name: String
    let id: Int
    let menus: [Menus]?
    let category: String
    let permalink: String?
    let remarks: String?
    let deliveryPrice: Int
    private enum CodingKeys: String, CodingKey {
        case delivery = "delivery"
        case address = "address"
        case payCard = "pay_card"
        case description = "description"
        case imageUrls = "image_urls"
        case openTime = "open_time"
        case closeTime = "close_time"
        case isEvent = "is_event"
        case eventArticles = "event_articles"
        case payBank = "pay_bank"
        case hit = "hit"
        case internalName = "internal_name"
        case isDeleted = "is_deleted"
        case phone = "phone"
        case chosung = "chosung"
        case name = "name"
        case id = "id"
        case menus = "menus"
        case category = "category"
        case permalink = "permalink"
        case remarks = "remarks"
        case deliveryPrice = "delivery_price"
    }
}
