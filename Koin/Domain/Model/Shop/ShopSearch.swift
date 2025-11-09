//
//  ShopSearch.swift
//  koin
//
//  Created by 홍기정 on 11/8/25.
//

import Foundation

struct ShopSearch {
    let shopNameSearchResults: [ShopNameSearchResult]
    let menuNameSearchResults: [MenuNameSearchResult]
}

struct ShopNameSearchResult: Codable {
    let shopId: Int
    let shopName: String
}

struct MenuNameSearchResult {
    let shopId: Int
    let shopName: String
    let menuName: String
}

extension ShopSearch {
    init(from dto: ShopSearchDto) {
        self.shopNameSearchResults = dto.shopNameSearchResults.map {
            return ShopNameSearchResult(from: $0)
        }
        self.menuNameSearchResults = dto.menuNameSearchResults.map {
            return MenuNameSearchResult(from: $0)
        }
    }
}

extension ShopNameSearchResult {
    init(from dto: ShopNameSearchResultDto) {
        self.shopId = dto.shopId
        self.shopName = dto.shopName
    }
}

extension MenuNameSearchResult {
    init(from dto: MenuNameSearchResultDto) {
        self.shopId = dto.shopId
        self.shopName = dto.shopName
        self.menuName = dto.menuName
    }
}
