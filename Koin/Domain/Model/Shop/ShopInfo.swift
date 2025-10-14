//
//  ShopInfo.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import Foundation

struct ShopInfo {
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

extension ShopInfo {
    
    static func empty() -> ShopInfo {
        return ShopInfo(name: " ", address: " ", openTime: " ", closeTime: " ", closedDays: [], phone: " ", introduction: " ", notice: " ", deliveryTips: [], ownerInfo: OwnerInfo(name: " ", shopName: " ", address: " ", companyRegistrationNumber: " "), origins: [])
    }
    
    static func dummy() -> ShopInfo {
        return ShopInfo(
            name: "김밥천국",
            address: "충청남도 천안시 동남구 병천면 충절로 1594",
            openTime: "08:00",
            closeTime: "20:00",
            closedDays: [.friday, .saturday],
            phone: "041-551-0095",
            introduction: "김밥천국에 오신 것을 환영합니다!\n다양한 김밥과 따뜻한 국물 요리로 가성비 좋은 한 끼를 제공합니다.\n신선한 재료와 정성으로 만든 메뉴로 고객님의 입맛을 사로잡겠습니다.\n아침, 점심, 저녁 언제나 든든한 식사를 원하신다면 김밥천국을 찾아주세요!\n가족 같은 따뜻한 서비스로 모시겠습니다.", notice: "*김밥천국 특별 이벤트*\n김밥 2줄 이상 주문 시 음료수 무료 제공!\n10,000원 이상 주문 시 떡볶이 20% 할인!\n매일 11시~14시 점심 특선 메뉴 15% 할인!\n단체 주문 시 추가 할인 문의 환영!\n배달은 언제나 빠르고 정확하게!",
            deliveryTips: [DeliveryTip(fromAmount: 20000, toAmount: 25000, fee: 2500),
                           DeliveryTip(fromAmount: 25000, toAmount: nil, fee: 0)],
            ownerInfo: OwnerInfo(name: "정해성",
                                 shopName: "김밥천국",
                                 address: "충청남도 천안시 동남구 병천면 충절로 1594",
                                 companyRegistrationNumber: "123-41-23412"),
            origins: [Origin(ingredient: "돼지고기", origin: "국내산"),
                      Origin(ingredient: "돼지고기", origin: "국내산"),
                      Origin(ingredient: "돼지고기", origin: "국내산"),
                      Origin(ingredient: "돼지고기", origin: "국내산"),
                      Origin(ingredient: "돼지고기", origin: "국내산"),
                      Origin(ingredient: "돼지고기", origin: "국내산"),
                      Origin(ingredient: "돼지고기", origin: "국내산"),
                      Origin(ingredient: "돼지고기", origin: "국내산"),
                      Origin(ingredient: "돼지고기", origin: "국내산"),
          ])
    }
}
