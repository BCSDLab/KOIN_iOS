//
//  EventsDto.swift
//  koin
//
//  Created by 김나훈 on 4/9/24.
//  nullable 주민경 2024/05/02

import Foundation

struct EventsDto: Decodable {
    let events: [EventDto]?
}

struct EventDto: Decodable {
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
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd"
        
        var startDateString: String = ""
        var endDateString: String = ""
        
        if let startDate = inputFormatter.date(from: startDate),
           let endDate = inputFormatter.date(from: endDate)
        {
            startDateString = outputFormatter.string(from: startDate)
            endDateString = outputFormatter.string(from: endDate)
        }
        
        return .init(shopId: shopId, shopName: shopName, title: title, content: content, thumbnailImages: thumbnailImages, startDate: startDateString, endDate: endDateString)
    }
}
