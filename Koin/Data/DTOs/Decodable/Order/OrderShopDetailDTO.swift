//
//  OrderShopDetailDTO.swift
//  koin
//
//  Created by 홍기정 on 10/31/25.
//

import Foundation

struct OrderShopDetailDto: Decodable {
    let shopID: Int
    let orderableShopID: Int
    let name: String
    let address: String
    let openTime: String?
    let closeTime: String?
    let closedDays: [ClosedDayDto]
    let phone: String
    let introduction: String?
    let notice: String?
    let deliveryTips: [DeliveryTipDto]
    let ownerInfo: OwnerInfoDto
    let origins: [OriginDto]

    enum CodingKeys: String, CodingKey {
        case shopID = "shop_id"
        case orderableShopID = "orderable_shop_id"
        case name, address
        case openTime = "open_time"
        case closeTime = "close_time"
        case closedDays = "closed_days"
        case phone, introduction, notice
        case deliveryTips = "delivery_tips"
        case ownerInfo = "owner_info"
        case origins
    }
}

enum ClosedDayDto: String, Decodable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
}

struct DeliveryTipDto: Codable {
    let fromAmount: Int
    let toAmount: Int?
    let fee: Int

    enum CodingKeys: String, CodingKey {
        case fromAmount = "from_amount"
        case toAmount = "to_amount"
        case fee
    }
}

struct OriginDto: Codable {
    let ingredient, origin: String
}

struct OwnerInfoDto: Codable {
    let name: String?
    let shopName: String?
    let address: String?
    let companyRegistrationNumber: String?

    enum CodingKeys: String, CodingKey {
        case name
        case shopName = "shop_name"
        case address
        case companyRegistrationNumber = "company_registration_number"
    }
}
