//
//  FetchShopReviewRequest.swift
//  koin
//
//  Created by 김나훈 on 8/11/24.
//

import Foundation

struct FetchShopReviewRequest: Encodable {
    let shopId: Int
    let page: Int
    let limit: Int = 10
    let sorter: ReviewSortType
}

enum ReviewSortType: String, Encodable, CaseIterable {
    case latest = "LATEST"
    case oldest = "OLDEST"
    case highestRaiting = "HIGHEST_RATING"
    case lowestRaiting = "LOWEST_RATING"
    
    var koreanDescription: String {
        switch self {
        case .latest: return "최신순"
        case .oldest: return "오래된순"
        case .highestRaiting: return "별점높은순"
        case .lowestRaiting: return "별점낮은순"
        }
    }
}
