//
//  OrderShopDetail.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import Foundation

struct OrderShopDetail {
    let name: String
    let address: String
    let openTime: String
    let closeTime: String
    let closedDays: [ClosedDay]
    let phone: String
    let introduction: String
    let notice: String
    let deliveryTips: [DeliveryTip]
    let ownerInfo: OwnerInfo
    let origins: [Origin]
}

enum ClosedDay: String {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
}

struct DeliveryTip {
    let fromAmount: Int
    let toAmount: Int?
    let fee: Int
}

struct OwnerInfo {
    let name: String
    let shopName: String
    let address: String
    let companyRegistrationNumber: String
}

struct Origin {
    let ingredient: String
    let origin: String
}

extension OrderShopDetail {
    
    init(from dto: OrderShopDetailDto) {
        self.name = dto.name
        self.address = dto.address
        self.openTime = dto.openTime ?? ""
        self.closeTime = dto.closeTime ?? ""
        self.closedDays = dto.closedDays.map {
            ClosedDay(from: $0)
        }
        self.phone = dto.phone
        self.introduction = dto.introduction ?? ""
        self.notice = dto.notice ?? ""
        self.deliveryTips = dto.deliveryTips.map {
            DeliveryTip(from: $0)
        }
        self.ownerInfo = OwnerInfo(from: dto.ownerInfo)
        self.origins = dto.origins.map {
            Origin(from: $0)
        }
    }
    
    static func empty() -> OrderShopDetail {
        return OrderShopDetail(name: "", address: "", openTime: "", closeTime: "", closedDays: [], phone: "", introduction: "", notice: "", deliveryTips: [], ownerInfo: OwnerInfo(name: "", shopName: "", address: "", companyRegistrationNumber: ""), origins: [])
    }
}

extension ClosedDay {
    init(from dto: ClosedDayDto) {
        switch dto {
        case .monday: self = .monday
        case .tuesday: self = .tuesday
        case .wednesday: self = .wednesday
        case .thursday: self = .thursday
        case .friday: self = .friday
        case .saturday: self = .saturday
        case .sunday: self = .sunday
        }
    }
}

extension DeliveryTip {
    init(from dto: DeliveryTipDto) {
        self.fromAmount = dto.fromAmount
        self.toAmount = dto.toAmount
        self.fee = dto.fee
    }
}

extension OwnerInfo {
    init(from dto: OwnerInfoDto) {
        self.name = dto.name ?? ""
        self.shopName = dto.shopName ?? ""
        self.address = dto.address ?? ""
        self.companyRegistrationNumber = dto.companyRegistrationNumber ?? ""
    }
}

extension Origin {
    init(from dto: OriginDto) {
        self.ingredient = dto.ingredient
        self.origin = dto.ingredient
    }
}
