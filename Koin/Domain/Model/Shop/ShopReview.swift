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
    var rating: Int
    var content: String
    var imageUrls: [String]
    var menuNames: [String]
    let createdAt: String
    let isMine: Bool
    var isModified: Bool
    let shopId: Int
    let reviewId: Int
}
