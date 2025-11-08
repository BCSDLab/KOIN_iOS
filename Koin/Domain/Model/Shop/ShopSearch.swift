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
    let shopID: Int
    let shopName: String
}

struct MenuNameSearchResult {
    let shopID: Int
    let shopName: String
    let menuName: String
}

