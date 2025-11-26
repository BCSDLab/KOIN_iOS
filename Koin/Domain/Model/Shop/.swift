
//
//  ShopSortType.swift
//  koin
//
//  Created by 김나훈 on 7/24/25.
//

import Foundation

enum ShopSortType: CaseIterable {
    case rating
    case review
    case basic
    
    var title: String {
        switch self {
        case .rating: return "별점 높은 순"
        case .review: return "리뷰순"
        case .basic:  return "기본순"
        }
    }

    var fetchSortType: FetchShopSortType {
        switch self {
        case .rating:
            return .ratingDesc
        case .review:
            return .reviewCountDesc
        case .basic:
            return .none
        }
    }
}
