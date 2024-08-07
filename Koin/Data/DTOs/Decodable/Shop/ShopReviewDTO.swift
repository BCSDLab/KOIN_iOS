//
//  ShopReviewDTO.swift
//  koin
//
//  Created by 김나훈 on 7/8/24.
//

import Foundation

struct ShopReviewDTO: Decodable {
    let count: Int
    let reviewStatistics: ReviewStatisticsDTO
    let reviews: [ReviewDTO]
    
    enum CodingKeys: String, CodingKey {
        case count
        case reviewStatistics = "review_statistics"
        case reviews
    }
}

struct ReviewStatisticsDTO: Decodable {
    let averageRating: Double
    let statistics: [String: Int]
    
    enum CodingKeys: String, CodingKey {
        case averageRating = "average_rating"
        case statistics
    }
}

struct ReviewDTO: Decodable {
    let reviewID: Int
    let rating: Int
    let nickName: String?
    let content: String
    let imageUrls: [String]
    let menuNames: [String]
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case reviewID = "review_id"
        case rating
        case nickName = "nick_name"
        case content
        case imageUrls = "image_urls"
        case menuNames = "menu_names"
        case createdAt = "created_at"
    }
}
