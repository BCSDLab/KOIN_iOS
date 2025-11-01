//
//  ShopDataDto.swift
//  Koin
//
//  Created by 김나훈 on 3/15/24.
//. nullable 주민경 2024/05/02

import Foundation

struct ShopDataDto: Decodable {
    let address: String?
    let delivery: Bool?
    let deliveryPrice: Int
    let description: String?
    let id: Int
    let imageUrls: [String]?
    let menuCategories: [Category]?
    let name: String?
    let open: [Open]?
    let payBank, payCard: Bool
    let phone: String?
    let shopCategories: [Category]?
    let updatedAt: String
    let bank: String?
    let accountNumber: String?

    enum CodingKeys: String, CodingKey {
        case address, delivery
        case deliveryPrice = "delivery_price"
        case description, id
        case imageUrls = "image_urls"
        case menuCategories = "menu_categories"
        case name
        case open
        case payBank = "pay_bank"
        case payCard = "pay_card"
        case phone
        case shopCategories = "shop_categories"
        case updatedAt = "updated_at"
        case bank
        case accountNumber = "account_number"
    }
    
    func toDomain() -> ShopData {
        return .init(address: address ?? "-", name: name ?? "", delivery: delivery ?? false, deliveryPrice: deliveryPrice, description: description ?? "-", imageUrls: imageUrls ?? [], open: open ?? [], payBank: payBank, payCard: payCard, phone: phone ?? "-", updatedAt: updatedAt, bank: bank, accountNumber: accountNumber)
    }
}

struct Category: Decodable {
    let id: Int
    let name: String
}


