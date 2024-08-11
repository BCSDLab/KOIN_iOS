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
    let limit: Int = 50
    let sorter: ReviewSortType
}

enum ReviewSortType: String, Encodable {
    case latest = "LASTEST"
    case oldest = "OLDEST"
    case highestRaiting = "HIGHEST_RATING"
    case lowestRaiting = "LOWEST_RATING"
}
