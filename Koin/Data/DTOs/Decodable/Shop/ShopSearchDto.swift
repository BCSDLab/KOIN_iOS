//
//  ShopSearchDto.swift
//  koin
//
//  Created by 홍기정 on 11/8/25.
//

import Foundation

struct ShopSearchDto: Decodable {
    let searchKeyword: String
    let processedSearchKeyword: String
    let shopNameSearchResultCount: Int
    let menuNameSearchResultCount: Int
    let shopNameSearchResults: [ShopNameSearchResultDto]
    let menuNameSearchResults: [MenuNameSearchResultDto]

    enum CodingKeys: String, CodingKey {
        case searchKeyword = "search_keyword"
        case processedSearchKeyword = "processed_search_keyword"
        case shopNameSearchResultCount = "shop_name_search_result_count"
        case menuNameSearchResultCount = "menu_name_search_result_count"
        case shopNameSearchResults = "shop_name_search_results"
        case menuNameSearchResults = "menu_name_search_results"
    }
}

// MARK: - MenuNameSearchResult
struct MenuNameSearchResultDto: Decodable {
    let shopId: Int
    let shopName: String
    let menuName: String

    enum CodingKeys: String, CodingKey {
        case shopId = "shop_id"
        case shopName = "shop_name"
        case menuName = "menu_name"
    }
}

// MARK: - ShopNameSearchResult
struct ShopNameSearchResultDto: Decodable {
    let shopId: Int
    let shopName: String

    enum CodingKeys: String, CodingKey {
        case shopId = "shop_id"
        case shopName = "shop_name"
    }
}
