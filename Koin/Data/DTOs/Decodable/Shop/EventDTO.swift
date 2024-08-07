//
//  EventsDTO.swift
//  koin
//
//  Created by 김나훈 on 4/9/24.
//  nullable 주민경 2024/05/02

import Foundation

struct EventsDTO: Decodable {
    let events: [EventDTO]?
}

struct EventDTO: Decodable {
    let shopId: Int
    let shopName: String
    let eventId: Int
    let title, content: String
    let thumbnailImages: [String]?
    let startDate, endDate: String
    
    enum CodingKeys: String, CodingKey {
        case title, content
        case thumbnailImages = "thumbnail_images"
        case startDate = "start_date"
        case endDate = "end_date"
        case shopId = "shop_id"
        case shopName = "shop_name"
        case eventId = "event_id"
    }
    
    func toDomain() -> ShopEvent {
        return .init(shopId: shopId, shopName: shopName, title: title, content: content, thumbnailImages: thumbnailImages, startDate: startDate, endDate: endDate)
    }
}
