//
//  Store.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/15.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct Store: Codable, Hashable, Identifiable {
    var delivery: Bool
    var address: String?
    var payCard: Bool
    var description: String?
    var imageUrls: [String]?
    var openTime: String?
    var closeTime: String?
    var isEvent: Bool
    var eventArticles: [StoreEvent]?
    var payBank: Bool
    var hit: Int
    var internalName: String
    var isDeleted: Bool
    var phone: String?
    var chosung: String
    var name: String
    var id: Int
    var menus: [Menus]?
    var category: String
    var permalink: String?
    var remarks: String?
    var deliveryPrice: Int

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

    init() {
        delivery = false
        address = nil
        payCard = false
        description = nil
        imageUrls = nil
        openTime = nil
        closeTime = nil
        isEvent = false
        eventArticles = nil
        payBank = false
        hit = 0
        internalName = ""
        isDeleted = false
        phone = nil
        chosung = ""
        name = ""
        id = -1
        menus = nil
        category = "S000"
        permalink = nil
        remarks = nil
        deliveryPrice = 0
    }
}
