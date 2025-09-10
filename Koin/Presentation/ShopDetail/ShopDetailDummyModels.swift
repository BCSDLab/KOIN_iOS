//
//  ShopDetailDummyModels.swift
//  koin
//
//  Created by 홍기정 on 9/9/25.
//

import Foundation

struct ShopDetailDummyModels {
    
    static let orderShopSummary = OrderShopSummary(
        shopID: 0,
        orderableShopID: 0,
        name: "굿모닝살로만치킨",
        introduction: "안녕하세요 굿모닝 살로만 치킨입니다!",
        isDeliveryAvailable: true,
        isTakeoutAvailable: false,
        payCard: true, payBank: true,
        minimumOrderAmount: 14000,
        ratingAverage: 4.1,
        reviewCount: 60,
        minimumDeliveryTip: 1500,
        maximumDeliveryTip: 3500,
        images: [OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: true),OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: false),OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: true)])
    
    static let orderShopMenusGroups = OrderShopMenusGroups(
        count: 0,
        menuGroups: [
            MenuGroup(id: 0, name: "메인메뉴"),
            MenuGroup(id: 1, name: "추천메뉴"),
            MenuGroup(id: 2, name: "세트메뉴"),
            MenuGroup(id: 3, name: "사이드"),
            MenuGroup(id: 4, name: "메인메뉴"),
            MenuGroup(id: 5, name: "추천메뉴"),
            MenuGroup(id: 6, name: "세트메뉴"),
            MenuGroup(id: 7, name: "사이드")
        ])
    
    static let orderShopMenus: [OrderShopMenus] = [
        OrderShopMenus(
            menuGroupID: 0,
            menuGroupName: "메인메뉴",
            menus: [
                OrderShopMenu(
                    id: 0,
                    name: "메인1",
                    description: "메인1입니다",
                    thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                    isSoldOut: false,
                    prices: [
                        Price(id: 0, name: .소, price: 5000),
                        Price(id: 1, name: .대, price: 9000)
                    ]),
                OrderShopMenu(
                    id: 1,
                    name: "메인2",
                    description: "메인2입니다",
                    thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                    isSoldOut: true,
                    prices: [
                        Price(id: 0, name: .소, price: 5000),
                        Price(id: 1, name: .대, price: 9000)
                    ])
            ]
        ),
        OrderShopMenus(
            menuGroupID: 1,
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
                        Price(id: 0, name: .특대, price: 20000),
                        Price(id: 1, name: .대, price: 15000)
                    ]
                )
            ]
        ),
        OrderShopMenus(
            menuGroupID: 1,
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
                        Price(id: 0, name: .특대, price: 20000),
                        Price(id: 0, name: .특대, price: 20000),
                        Price(id: 0, name: .특대, price: 20000),
                        Price(id: 1, name: .대, price: 15000)
                    ]
                )
            ]
        ),
        OrderShopMenus(
            menuGroupID: 1,
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
            menuGroupID: 0,
            menuGroupName: "메인메뉴",
            menus: [
                OrderShopMenu(
                    id: 0,
                    name: "메인1",
                    description: "메인1입니다",
                    thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                    isSoldOut: false,
                    prices: [
                        Price(id: 0, name: .소, price: 5000),
                        Price(id: 1, name: .대, price: 9000)
                    ]),
                OrderShopMenu(
                    id: 1,
                    name: "메인2",
                    description: "메인2입니다",
                    thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                    isSoldOut: true,
                    prices: [
                        Price(id: 0, name: .소, price: 5000),
                        Price(id: 1, name: .대, price: 9000)
                    ])
            ]
        ),
        OrderShopMenus(
            menuGroupID: 1,
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
                        Price(id: 0, name: .특대, price: 20000),
                        Price(id: 1, name: .대, price: 15000)
                    ]
                )
            ]
        ),
        OrderShopMenus(
            menuGroupID: 1,
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
                        Price(id: 0, name: .특대, price: 20000),
                        Price(id: 0, name: .특대, price: 20000),
                        Price(id: 0, name: .특대, price: 20000),
                        Price(id: 1, name: .대, price: 15000)
                    ]
                )
            ]
        ),
        OrderShopMenus(
            menuGroupID: 1,
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
