//
//  orderMenuDTO.swift
//  koin
//
//  Created by 김성민 on 10/11/25.
//
import Foundation

// MARK: - OrderMenuDTO
struct OrderMenuDTO: Decodable {
    let id: Int
    let name, description: String
    let images: [String]
    let menuPrices: [MenuPrice]
    let optionGroups: [OptionGroup]

    enum CodingKeys: String, CodingKey {
        case id, name, description, images, menuPrices
        case optionGroups = "option_groups"
    }
}

struct OptionGroup: Decodable {
    let id: Int
    let name, description: String
    let isRequired: Bool
    let minSelect, maxSelect: Int
    let options: [MenuPrice]

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case isRequired = "is_required"
        case minSelect = "min_select"
        case maxSelect = "max_select"
        case options
    }
}

// MARK: - Price
struct MenuPrice: Decodable {
    let id: Int
    let name: String?
    let price: Int
}
