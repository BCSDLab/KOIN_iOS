//
//  OrderShop.swift
//  koin
//
//  Created by 이은지 on 6/30/25.
//

import UIKit

struct OrderShop {
    let image: UIImage?
    let name: String
    let reviewCount: Int
    let averageRate: Double
    let deliveryLabel: String
}

extension OrderShop {
    static func dummy() -> [OrderShop] {
        return [
            OrderShop(
                image: UIImage.appImage(asset: .defaultMenuImage),
                name: "치킨나라 강남점",
                reviewCount: 0,
                averageRate: 0.0,
                deliveryLabel: "2000"
            ),
            OrderShop(
                image: UIImage.appImage(asset: .defaultMenuImage),
                name: "피자월드 신촌점",
                reviewCount: 3,
                averageRate: 4.5,
                deliveryLabel: "1500"
            ),
            OrderShop(
                image: UIImage.appImage(asset: .defaultMenuImage),
                name: "한식천국 잠실점",
                reviewCount: 12,
                averageRate: 4.8,
                deliveryLabel: "1500"
            ),
            OrderShop(
                image: UIImage.appImage(asset: .defaultMenuImage),
                name: "한식천국 잠실점",
                reviewCount: 12,
                averageRate: 4.8,
                deliveryLabel: "1500"
            ),
            OrderShop(
                image: UIImage.appImage(asset: .defaultMenuImage),
                name: "한식천국 잠실점",
                reviewCount: 12,
                averageRate: 4.8,
                deliveryLabel: "1500"
            ),
            OrderShop(
                image: UIImage.appImage(asset: .defaultMenuImage),
                name: "한식천국 잠실점",
                reviewCount: 12,
                averageRate: 4.8,
                deliveryLabel: "1500"
            )
        ]
    }
}
