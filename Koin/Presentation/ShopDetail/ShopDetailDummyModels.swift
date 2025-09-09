//
//  ShopDetailDummyModels.swift
//  koin
//
//  Created by 홍기정 on 9/9/25.
//

import Foundation

struct ShopDetailDummyModels {
    
    static let urls = [
        "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
        "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
        "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
        "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
        "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg"
    ]
    static let orderShop = OrderShop(shopId: 0, orderableShopId: 0, name: "NAME", isDeliveryAvailable: true, isTakeoutAvailable: true, serviceEvent: true,minimumOrderAmount: 15000, ratingAverage: 4.8, reviewCount: 5, minimumDeliveryTip: 0, maximumDeliveryTip: 3000, isOpen: true, categoryIds: [], images: [OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: true),OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: false),OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: true)], openStatus: "")
    static let orderShopMenusGroup = [
        OrderShopMenusGroup(menuGroupID: 0, menuGroupName: "메인메뉴", menus: [
            OrderShopMenu(id: 0, name: "메인1", description: "메인1입니다", thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: false, prices: [
                Price(id: 0, name: .소, price: 5000),
                Price(id: 1, name: .대, price: 9000)
            ]),
            OrderShopMenu(id: 1, name: "메인2", description: "메인2입니다", thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: true, prices: [
                Price(id: 0, name: .소, price: 5000),
                Price(id: 1, name: .대, price: 9000)
            ])
        ]),
        OrderShopMenusGroup(menuGroupID: 1, menuGroupName: "추천메뉴", menus: [
            OrderShopMenu(id: 2, name: "추천1", description: nil, thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: false, prices: [
                Price(id: 0, name: nil, price: 5000)
            ]),
            OrderShopMenu(id: 3, name: "추천2", description: "추천2맛있어요", thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: true, prices: [
                Price(id: 0, name: .특대, price: 20000),
                Price(id: 1, name: .대, price: 15000)
            ])
        ]),
        OrderShopMenusGroup(menuGroupID: 1, menuGroupName: "세트메뉴", menus: [
            OrderShopMenu(id: 2, name: "세트1", description: nil, thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: false, prices: [
                Price(id: 0, name: nil, price: 5000)
            ]),
            OrderShopMenu(id: 3, name: "세트2", description: "세트2양많아요", thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: true, prices: [
                Price(id: 0, name: .특대, price: 20000),
                Price(id: 0, name: .특대, price: 20000),
                Price(id: 0, name: .특대, price: 20000),
                Price(id: 1, name: .대, price: 15000)
            ])
        ]),
        OrderShopMenusGroup(menuGroupID: 1, menuGroupName: "사이드", menus: [
            OrderShopMenu(id: 2, name: "사이드1", description: nil, thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: false, prices: [
                Price(id: 0, name: nil, price: 5000)
            ])
        ]),
        OrderShopMenusGroup(menuGroupID: 0, menuGroupName: "메인메뉴", menus: [
            OrderShopMenu(id: 0, name: "메인1", description: "메인1입니다", thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: false, prices: [
                Price(id: 0, name: .소, price: 5000),
                Price(id: 1, name: .대, price: 9000)
            ]),
            OrderShopMenu(id: 1, name: "메인2", description: "메인2입니다", thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: true, prices: [
                Price(id: 0, name: .소, price: 5000),
                Price(id: 1, name: .대, price: 9000)
            ])
        ]),
        OrderShopMenusGroup(menuGroupID: 1, menuGroupName: "추천메뉴", menus: [
            OrderShopMenu(id: 2, name: "추천1", description: nil, thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: false, prices: [
                Price(id: 0, name: nil, price: 5000)
            ]),
            OrderShopMenu(id: 3, name: "추천2", description: "추천2맛있어요", thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: true, prices: [
                Price(id: 0, name: .특대, price: 20000),
                Price(id: 1, name: .대, price: 15000)
            ])
        ]),
        OrderShopMenusGroup(menuGroupID: 1, menuGroupName: "세트메뉴", menus: [
            OrderShopMenu(id: 2, name: "세트1", description: nil, thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: false, prices: [
                Price(id: 0, name: nil, price: 5000)
            ]),
            OrderShopMenu(id: 3, name: "세트2", description: "세트2양많아요", thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: true, prices: [
                Price(id: 0, name: .특대, price: 20000),
                Price(id: 0, name: .특대, price: 20000),
                Price(id: 0, name: .특대, price: 20000),
                Price(id: 1, name: .대, price: 15000)
            ])
        ]),
        OrderShopMenusGroup(menuGroupID: 1, menuGroupName: "사이드", menus: [
            OrderShopMenu(id: 2, name: "사이드1", description: nil, thumbnailImage: "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg", isSoldOut: false, prices: [
                Price(id: 0, name: nil, price: 5000)
            ])
        ])
    ]
}
