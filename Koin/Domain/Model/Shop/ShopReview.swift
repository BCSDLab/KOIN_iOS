//
//  ShopReview.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Foundation

struct ShopReview {
    let reviewStatistics: StatisticsDTO
    let review: [Review]
}

struct Review {
    let nickName: String
    let rating: Int
    let content: String
    let imageUrls: [String]
    let menuNames: [String]
    let createdAt: String
    let isMine: Bool
    let isModified: Bool
    let shopId: Int
    let reviewId: Int
}
