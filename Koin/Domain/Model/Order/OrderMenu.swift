//
//  OrderMenu.swift
//  koin
//
//  Created by 김성민 on 10/12/25.
//

import Foundation

struct OrderMenu {
    let id: Int
    let name: String
    let description: String
    let images: [String]
    let prices: [DetailMenuPrice]
    let optionGroups: [MenuOptionGroup]
}

struct DetailMenuPrice {
    let id: Int
    let name: String?
    let amount: Int
}

struct MenuOptionGroup {
    let id: Int
    let name: String
    let description: String
    let isRequired: Bool
    let minSelect: Int
    let maxSelect: Int
    let options: [MenuOption]
}

struct MenuOption {
    let id: Int
    let name: String
    let extraAmount: Int
}

extension OrderMenu {
    init(from dto: OrderMenuDTO) {
        self.id = dto.id
        self.name = dto.name
        self.description = dto.description
        self.images = dto.images
        self.prices = dto.menuPrices.map { DetailMenuPrice(from: $0) }
        self.optionGroups = dto.optionGroups.map { MenuOptionGroup(from: $0) }
    }
}

extension DetailMenuPrice {
    init(from dto: MenuPrice) {
        self.id = dto.id
        self.name = dto.name
        self.amount = dto.price
    }
}

extension MenuOptionGroup {
    init(from dto: OptionGroup) {
        self.id = dto.id
        self.name = dto.name
        self.description = dto.description
        self.isRequired = dto.isRequired
        self.minSelect = dto.minSelect
        self.maxSelect = dto.maxSelect
        self.options = dto.options.map { MenuOption(from: $0) }
    }
}

extension MenuOption {
    init(from dto: MenuPrice) {
        self.id = dto.id
        self.name = dto.name ?? ""
        self.extraAmount = dto.price
    }
}

