//
//  FetchOrderShopListRequest.swift
//  koin
//
//  Created by 이은지 on 7/6/25.
//

import Foundation

struct FetchOrderShopListRequest: Encodable {
    var sorter: FetchOrderShopSortType
    var filter: [FetchOrderShopFilterType]
}

enum FetchOrderShopFilterType: String, Encodable {
    case isOpen = "IS_OPEN"
    case deliveryAvailable = "DELIVERY_AVAILABLE"
    case takeoutAvailable = "TAKEOUT_AVAILABLE"
    case freeDeliveryTip = "FREE_DELIVERY_TIP"
}

enum FetchOrderShopSortType: String, Encodable {
    case none = "NONE"
    case count = "COUNT"
    case countAsc = "COUNT_ASC"
    case countDesc = "COUNT_DESC"
    case rating = "RATING"
    case ratingAsc = "RATING_ASC"
    case ratingDesc = "RATING_DESC"
}
