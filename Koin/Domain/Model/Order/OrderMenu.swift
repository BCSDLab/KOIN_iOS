//
//  OrderMenu.swift
//  koin
//
//  Created by 김성민 on 10/11/25.
//

import Foundation

struct MenuGroup: Equatable {
    let id: Int
    let name: String
    let menus: [MenuSummary]
}

struct MenuSummary: Equatable {
    let id: Int
    let name: String
    let description: String?
    let thumbnailURL: URL?
    let isSoldOut: Bool
    let prices: [MenuPrice]
}

struct MenuDetail: Equatable {
    let id: Int
    let name: String
    let description: String?
    let images: [URL]
    let prices: [MenuPrice]
    let optionGroups: [OptionGroup]
}

struct MenuPrice: Equatable {
    let id: Int
    let name: String?
    let amount: Int
}

struct OptionGroup: Equatable {
    let id: Int
    let name: String
    let description: String
    let isRequired: Bool
    let minSelect: Int
    let maxSelect: Int
    let options: [MenuOption]
}

struct MenuOption: Equatable {
    let id: Int
    let name: String
    let extraAmount: Int
}
