//
//  ShopReview.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Foundation

struct ShopReview {
    let statistics: StatisticsDto
    let totalPage: Int
    let currentPage: Int
    let totalCount: Int
    let currentCount: Int
    let reviews: [Review]
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
    var isReported: Bool
    let shopId: Int
    let reviewId: Int
}
