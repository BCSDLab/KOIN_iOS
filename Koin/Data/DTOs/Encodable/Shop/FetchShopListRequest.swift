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
}

enum FetchShopSortType: String, Encodable {
    case none = "NONE"
    case count = "COUNT"
    case rating = "RATING"
}

enum FetchShopFilterType: String, Encodable {
    case none = ""
    case open = "OPEN"
    case delivery = "DELIVERY"
}
