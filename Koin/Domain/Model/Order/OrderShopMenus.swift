//
//  OrderShopMenus.swift
//  koin
//
//  Created by 홍기정 on 9/10/25.
//

import Foundation

// MARK: - OrderShopMenus
struct OrderShopMenus {
    let menuGroupId: Int
    let menuGroupName: String
    let menus: [OrderShopMenu]
}

// MARK: - OrderShopMenu
struct OrderShopMenu {
    let id: Int
    let name: String
    let description: String?
    let thumbnailImage: String
    let isSoldOut: Bool
    let prices: [Price]
}

// MARK: - Price
struct Price {
    let id: Int
    let name: Name?
    let price: Int
}

enum Name: String {
    case small = "소"
    case medium = "중"
    case large = "대"
    case extraLarge = "특대"
}

extension OrderShopMenus {
    
    static func dummy() -> [OrderShopMenus] {
        return [
            OrderShopMenus(
                menuGroupId: 0,
                menuGroupName: "메인메뉴",
                menus: [
                    OrderShopMenu(
                        id: 0,
                        name: "메인1",
                        description: "메인1입니다",
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: false,
                        prices: [
                            Price(id: 0, name: .small, price: 5000),
                            Price(id: 1, name: .large, price: 9000)
                        ]),
                    OrderShopMenu(
                        id: 1,
                        name: "메인2",
                        description: "메인2입니다",
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: true,
                        prices: [
                            Price(id: 0, name: .small, price: 5000),
                            Price(id: 1, name: .large, price: 9000)
                        ])
                ]
            ),
            OrderShopMenus(
                menuGroupId: 1,
                menuGroupName: "추천메뉴",
                menus: [
                    OrderShopMenu(
                        id: 2,
                        name: "추천1",
                        description: nil,
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: false,
                        prices: [
                            Price(id: 0, name: nil, price: 5000)
                        ]
                    ),
                    OrderShopMenu(
                        id: 3,
                        name: "추천2",
                        description: "추천2맛있어요",
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: true,
                        prices: [
                            Price(id: 0, name: .extraLarge, price: 20000),
                            Price(id: 1, name: .large, price: 15000)
                        ]
                    )
                ]
            ),
            OrderShopMenus(
                menuGroupId: 1,
                menuGroupName: "세트메뉴",
                menus: [
                    OrderShopMenu(
                        id: 2,
                        name: "세트1",
                        description: nil,
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: false,
                        prices: [
                            Price(id: 0, name: nil, price: 5000)
                        ]
                    ),
                    OrderShopMenu(
                        id: 3,
                        name: "세트2",
                        description: "세트2양많아요",
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: true,
                        prices: [
                            Price(id: 0, name: .extraLarge, price: 20000),
                            Price(id: 0, name: .extraLarge, price: 20000),
                            Price(id: 0, name: .extraLarge, price: 20000),
                            Price(id: 1, name: .large, price: 15000)
                        ]
                    )
                ]
            ),
            OrderShopMenus(
                menuGroupId: 1,
                menuGroupName: "사이드",
                menus: [
                    OrderShopMenu(
                        id: 2,
                        name: "사이드1",
                        description: nil,
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: false,
                        prices: [
                            Price(id: 0, name: nil, price: 5000)
                        ]
                    )
                ]
            ),
            OrderShopMenus(
                menuGroupId: 0,
                menuGroupName: "메인메뉴",
                menus: [
                    OrderShopMenu(
                        id: 0,
                        name: "메인1",
                        description: "메인1입니다",
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: false,
                        prices: [
                            Price(id: 0, name: .small, price: 5000),
                            Price(id: 1, name: .large, price: 9000)
                        ]),
                    OrderShopMenu(
                        id: 1,
                        name: "메인2",
                        description: "메인2입니다",
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: true,
                        prices: [
                            Price(id: 0, name: .small, price: 5000),
                            Price(id: 1, name: .large, price: 9000)
                        ])
                ]
            ),
            OrderShopMenus(
                menuGroupId: 1,
                menuGroupName: "추천메뉴",
                menus: [
                    OrderShopMenu(
                        id: 2,
                        name: "추천1",
                        description: nil,
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: false,
                        prices: [
                            Price(id: 0, name: nil, price: 5000)
                        ]
                    ),
                    OrderShopMenu(
                        id: 3,
                        name: "추천2",
                        description: "추천2맛있어요",
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: true,
                        prices: [
                            Price(id: 0, name: .extraLarge, price: 20000),
                            Price(id: 1, name: .large, price: 15000)
                        ]
                    )
                ]
            ),
            OrderShopMenus(
                menuGroupId: 1,
                menuGroupName: "세트메뉴",
                menus: [
                    OrderShopMenu(
                        id: 2,
                        name: "세트1",
                        description: nil,
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: false,
                        prices: [
                            Price(id: 0, name: nil, price: 5000)
                        ]
                    ),
                    OrderShopMenu(
                        id: 3,
                        name: "세트2",
                        description: "세트2양많아요",
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: true,
                        prices: [
                            Price(id: 0, name: .extraLarge, price: 20000),
                            Price(id: 0, name: .extraLarge, price: 20000),
                            Price(id: 0, name: .extraLarge, price: 20000),
                            Price(id: 1, name: .large, price: 15000)
                        ]
                    )
                ]
            ),
            OrderShopMenus(
                menuGroupId: 1,
                menuGroupName: "사이드",
                menus: [
                    OrderShopMenu(
                        id: 2,
                        name: "사이드1",
                        description: nil,
                        thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                        isSoldOut: false,
                        prices: [
                            Price(id: 0, name: nil, price: 5000)
                        ]
                    )
                ]
            )
        ]
    }
}
