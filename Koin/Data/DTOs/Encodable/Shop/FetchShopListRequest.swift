//
//  FetchShopListRequest.swift
//  koin
//
//  Created by 김나훈 on 8/14/24.
//

import Foundation

struct FetchShopListRequest: Encodable {
    var sorter: FetchShopSortType
    var filter: [FetchShopFilterType]
    var query: String?

    enum CodingKeys: String, CodingKey {
        case sorter
        case filter
        case query
    }
}

enum FetchShopSortType: String, Encodable {
    case none = "NONE"
    case count = "COUNT"
    case countAsc = "COUNT_ASC"
    case countDesc = "COUNT_DESC"
    case rating = "RATING"
    case ratingAsc = "RATING_ASC"
    case ratingDesc = "RATING_DESC"
}

enum FetchShopFilterType: String, Encodable {
    case open = "OPEN"
    case delivery = "DELIVERY"
}
