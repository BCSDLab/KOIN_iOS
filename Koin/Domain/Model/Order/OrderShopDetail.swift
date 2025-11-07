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
    
    init(from dto: ShopDataDto) {
        self.name = dto.name ?? ""
        self.address = dto.address ?? ""
        
        if let open = dto.open {
            var closedDays: [ClosedDay] = []
            open.forEach {
                if $0.closed, let closedDay = ClosedDay(rawValue: $0.dayOfWeek) {
                    closedDays.append(closedDay)
                }
            }
            self.closedDays = closedDays
        }
        
        else {
            self.closedDays = []
        }
        self.openTime = dto.openTime ?? ""
        self.closeTime = dto.closeTime ?? ""
        
        self.phone = dto.phone ?? ""
        self.introduction = dto.description ?? ""
        self.notice = "" // FIXME: 대응되는 요소가 없어서 빈칸으로 두었습니다
        self.deliveryTips = []
        self.ownerInfo = OwnerInfo(name: "", shopName: "", address: "", companyRegistrationNumber: "")
        self.origins = []
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
    
    init(deliveryPrice: Int) {
        self.fromAmount = 0 // FIXME: 0은 임의로 넣어뒀습니다. 디자인 변경안 나오면 수정하겠습니다
        self.toAmount = nil
        self.fee = deliveryPrice
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
